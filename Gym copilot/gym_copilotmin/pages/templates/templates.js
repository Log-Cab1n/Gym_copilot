const db = require('../../utils/db.js')
const dataUtil = require('../../utils/data.js')

function formatDate(dateStr) {
  const date = new Date(dateStr)
  return `${date.getFullYear()}/${(date.getMonth() + 1).toString().padStart(2, '0')}/${date.getDate().toString().padStart(2, '0')}`
}

Page({
  data: {
    templates: [],
    showAddModal: false,
    templateName: '',
    selectedBodyPart: null,
    exercises: [],
    availableExercises: [],
    templateExercises: [],
    bodyParts: [
      { key: 'chest', name: '胸' },
      { key: 'back', name: '背' },
      { key: 'legs', name: '腿' },
      { key: 'shoulders', name: '肩' },
      { key: 'arms', name: '臂' },
      { key: 'core', name: '腹' }
    ],
    showConfigModal: false,
    configExercise: null,
    configWeight: '',
    configReps: '',
    configSets: '1',
    editingExerciseIndex: -1,
    tagNames: { chest: '胸', back: '背', legs: '腿', shoulders: '肩', arms: '臂', core: '腹' }
  },

  onLoad() {
    this.setData({ exercises: db.getExercises() })
    this.loadTemplates()
  },

  onShow() {
    this.loadTemplates()
  },

  loadTemplates() {
    const templates = db.getWorkoutTemplates()
    templates.forEach(t => {
      try {
        t._exercises = JSON.parse(t.exercisesJson)
      } catch (e) {
        t._exercises = []
      }
      t._createdAtFormatted = formatDate(t.createdAt)
    })
    this.setData({ templates })
  },

  showAdd() {
    this.setData({
      showAddModal: true,
      templateName: '',
      selectedBodyPart: null,
      templateExercises: [],
      configExercise: null,
      configWeight: '',
      configReps: '',
      configSets: '1',
      editingExerciseIndex: -1,
    })
  },

  hideAdd() {
    this.setData({ showAddModal: false })
  },

  onNameInput(e) {
    this.setData({ templateName: e.detail.value })
  },

  selectBodyPart(e) {
    const tag = e.currentTarget.dataset.key
    const selectedBodyPart = this.data.selectedBodyPart === tag ? null : tag
    let availableExercises = selectedBodyPart
      ? this.data.exercises.filter(e => e.tag === selectedBodyPart)
      : []
    availableExercises = availableExercises.map(ex => ({
      ...ex,
      _selected: this.data.templateExercises.some(te => te.exerciseId === ex.id)
    }))
    this.setData({ selectedBodyPart, availableExercises })
  },

  onExerciseCheckboxChange(e) {
    const exerciseId = e.currentTarget.dataset.id
    const exercise = this.data.availableExercises.find(ex => ex.id === exerciseId)
    const isChecked = e.detail.value.length > 0

    if (isChecked) {
      this.setData({
        configExercise: exercise,
        configWeight: '',
        configReps: '',
        configSets: '1',
        editingExerciseIndex: -1,
        showConfigModal: true,
      })
    } else {
      const templateExercises = this.data.templateExercises.filter(
        te => te.exerciseId !== exerciseId
      )
      this.setData({ templateExercises })
    }
  },

  onConfigWeightInput(e) {
    this.setData({ configWeight: e.detail.value })
  },

  onConfigRepsInput(e) {
    this.setData({ configReps: e.detail.value })
  },

  onConfigSetsInput(e) {
    this.setData({ configSets: e.detail.value })
  },

  hideConfigModal() {
    if (this.data.editingExerciseIndex === -1 && this.data.configExercise) {
      const exerciseId = this.data.configExercise.id
      const templateExercises = this.data.templateExercises.filter(
        te => te.exerciseId !== exerciseId
      )
      this.setData({ templateExercises, showConfigModal: false })
    } else {
      this.setData({ showConfigModal: false })
    }
  },

  confirmConfig() {
    const { configExercise, configWeight, configReps, configSets, templateExercises, editingExerciseIndex } = this.data
    if (!configExercise) return

    const config = {
      exerciseId: configExercise.id,
      exerciseName: configExercise.name,
      exerciseTag: configExercise.tag,
      weight: parseFloat(configWeight) || 0,
      reps: parseInt(configReps) || 0,
      sets: parseInt(configSets) || 1,
    }

    let newExercises
    if (editingExerciseIndex >= 0) {
      newExercises = [...templateExercises]
      newExercises[editingExerciseIndex] = config
    } else {
      newExercises = templateExercises.filter(te => te.exerciseId !== configExercise.id)
      newExercises.push(config)
    }

    this.setData({
      templateExercises: newExercises,
      showConfigModal: false,
      configExercise: null,
      configWeight: '',
      configReps: '',
      configSets: '1',
      editingExerciseIndex: -1,
    })
  },

  editExerciseConfig(e) {
    const index = e.currentTarget.dataset.index
    const config = this.data.templateExercises[index]
    const exercise = this.data.exercises.find(ex => ex.id === config.exerciseId)
    this.setData({
      configExercise: exercise,
      configWeight: config.weight.toString(),
      configReps: config.reps.toString(),
      configSets: config.sets.toString(),
      editingExerciseIndex: index,
      showConfigModal: true,
    })
  },

  removeFromTemplate(e) {
    const index = e.currentTarget.dataset.index
    const templateExercises = this.data.templateExercises.filter((_, i) => i !== index)
    this.setData({ templateExercises })
  },

  clearAllExercises() {
    this.setData({ templateExercises: [] })
  },

  saveTemplate() {
    const { templateName, selectedBodyPart, templateExercises } = this.data
    if (!templateName.trim()) {
      wx.showToast({ title: '请输入模板名称', icon: 'none' })
      return
    }
    if (!selectedBodyPart) {
      wx.showToast({ title: '请选择训练部位', icon: 'none' })
      return
    }
    if (templateExercises.length === 0) {
      wx.showToast({ title: '请添加动作', icon: 'none' })
      return
    }
    db.saveWorkoutTemplate({
      name: templateName.trim(),
      bodyPart: selectedBodyPart,
      exercises: templateExercises,
    })
    this.setData({ showAddModal: false })
    this.loadTemplates()
    wx.showToast({ title: '模板已保存', icon: 'success' })
  },

  deleteTemplate(e) {
    const id = e.currentTarget.dataset.id
    wx.showModal({
      title: '删除模板',
      content: '确定要删除这个训练模板吗？',
      confirmColor: '#CF6679',
      success: (res) => {
        if (res.confirm) {
          db.deleteWorkoutTemplate(id)
          this.loadTemplates()
          wx.showToast({ title: '已删除', icon: 'success' })
        }
      },
    })
  },

  startFromTemplate(e) {
    const id = parseInt(e.currentTarget.dataset.id)
    const template = this.data.templates.find(t => t.id === id)
    if (!template) return
    const exercises = JSON.parse(template.exercisesJson)
    const templateData = {
      bodyPart: template.bodyPart,
      exercises,
    }
    wx.navigateTo({
      url: `/pages/workout/workout?template=${encodeURIComponent(JSON.stringify(templateData))}`,
    })
  },

  getTagDisplayName(tag) {
    return dataUtil.getTagDisplayName(tag)
  },

  isExerciseSelected(exerciseId) {
    return this.data.templateExercises.some(te => te.exerciseId === exerciseId)
  },
})
