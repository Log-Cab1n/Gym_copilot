const db = require('../../utils/db.js')
const dataUtil = require('../../utils/data.js')

Page({
  data: {
    searchText: '',
    selectedTag: null,
    tags: [],
    exercises: [],
    filteredExercises: [],
    exerciseUsageStats: {},
    showAddModal: false,
    showDetailModal: false,
    showHistoryModal: false,
    selectedExercise: null,
    selectedExerciseStats: { useCount: 0, lastUsedDate: null },
    exerciseHistory: [],
    newExerciseName: '',
    newExerciseTag: 'chest',
    newExerciseMuscles: '',
    tagNames: { chest: '胸', back: '背', legs: '腿', shoulders: '肩', arms: '臂', core: '腹' },
    tagAbbreviations: { chest: '胸', back: '背', legs: '腿', shoulders: '肩', arms: '臂', core: '核' }
  },

  onLoad() {
    const tags = dataUtil.getAllTags().map(tag => ({
      key: tag,
      name: dataUtil.getTagDisplayName(tag)
    }))
    this.setData({ tags })
    this.loadExercises()
  },

  onShow() {
    this.loadExercises()
  },

  loadExercises() {
    const exercises = db.getExercises()
    const usageStats = this._getExerciseUsageStats()
    const usageMap = {}
    usageStats.forEach(stat => {
      usageMap[stat.exerciseId] = {
        useCount: stat.useCount,
        lastUsedDate: stat.lastUsedDate
      }
    })
    exercises.sort((a, b) => {
      const countA = usageMap[a.id]?.useCount || 0
      const countB = usageMap[b.id]?.useCount || 0
      return countB - countA
    })
    this.setData({ exercises, exerciseUsageStats: usageMap })
    this.filterExercises()
  },

  _getExerciseUsageStats() {
    try {
      return wx.getStorageSync('exercise_usage') || []
    } catch (e) {
      return []
    }
  },

  filterExercises() {
    const { exercises, selectedTag, searchText, exerciseUsageStats } = this.data
    let filtered = exercises.filter(e => {
      const matchesTag = !selectedTag || e.tag === selectedTag
      const matchesSearch = !searchText || e.name.toLowerCase().includes(searchText.toLowerCase())
      return matchesTag && matchesSearch
    })
    filtered.sort((a, b) => {
      const countA = exerciseUsageStats[a.id]?.useCount || 0
      const countB = exerciseUsageStats[b.id]?.useCount || 0
      return countB - countA
    })
    this.setData({ filteredExercises: filtered })
  },

  onSearchInput(e) {
    this.setData({ searchText: e.detail.value })
    this.filterExercises()
  },

  clearSearch() {
    this.setData({ searchText: '' })
    this.filterExercises()
  },

  selectTag(e) {
    const tag = e.currentTarget.dataset.tag
    const newTag = this.data.selectedTag === tag ? null : tag
    this.setData({ selectedTag: newTag })
    this.filterExercises()
  },

  getTagAbbreviation(tag) {
    const names = {
      chest: '胸',
      back: '背',
      legs: '腿',
      shoulders: '肩',
      arms: '臂',
      core: '腹'
    }
    return names[tag] || tag.substring(0, 1).toUpperCase()
  },

  formatDate(dateStr) {
    if (!dateStr) return ''
    try {
      const date = new Date(dateStr)
      const month = (date.getMonth() + 1).toString().padStart(2, '0')
      const day = date.getDate().toString().padStart(2, '0')
      return `${month}/${day}`
    } catch (e) {
      return dateStr
    }
  },

  showExerciseDetail(e) {
    const id = e.currentTarget.dataset.id
    const exercise = this.data.exercises.find(ex => ex.id === id)
    if (!exercise) return
    const stats = this.data.exerciseUsageStats[id] || { useCount: 0, lastUsedDate: null }
    this.setData({
      selectedExercise: exercise,
      selectedExerciseStats: stats,
      showDetailModal: true
    })
  },

  hideDetailModal() {
    this.setData({ showDetailModal: false, selectedExercise: null })
  },

  showExerciseHistory() {
    const exercise = this.data.selectedExercise
    if (!exercise || !exercise.id) return
    const history = this._getExerciseHistory(exercise.id)
    this.setData({
      exerciseHistory: history,
      showDetailModal: false,
      showHistoryModal: true
    })
  },

  hideHistoryModal() {
    this.setData({ showHistoryModal: false, exerciseHistory: [] })
  },

  _getExerciseHistory(exerciseId) {
    const records = db.getWorkoutRecords()
    const history = []
    records.forEach(record => {
      if (record.exerciseSets) {
        record.exerciseSets.forEach(set => {
          if (set.exerciseId === exerciseId) {
            history.push({
              dateTime: record.dateTime,
              weight: set.weight,
              reps: set.reps,
              setNumber: set.setNumber,
              fatigueLevel: set.fatigueLevel || 0
            })
          }
        })
      }
    })
    return history.sort((a, b) => new Date(b.dateTime) - new Date(a.dateTime))
  },

  formatDateTime(dateTimeStr) {
    if (!dateTimeStr) return ''
    try {
      const date = new Date(dateTimeStr)
      const year = date.getFullYear()
      const month = (date.getMonth() + 1).toString().padStart(2, '0')
      const day = date.getDate().toString().padStart(2, '0')
      const hours = date.getHours().toString().padStart(2, '0')
      const minutes = date.getMinutes().toString().padStart(2, '0')
      return `${year}/${month}/${day} ${hours}:${minutes}`
    } catch (e) {
      return dateTimeStr
    }
  },

  deleteExercise(e) {
    const id = e.currentTarget.dataset.id
    wx.showModal({
      title: '确认删除',
      content: '确定要删除这个动作吗？此操作不可撤销。',
      confirmColor: '#CF6679',
      success: (res) => {
        if (res.confirm) {
          db.deleteExercise(id)
          this.loadExercises()
          wx.showToast({ title: '已删除', icon: 'success' })
        }
      }
    })
  },

  showAddModal() {
    this.setData({
      showAddModal: true,
      newExerciseName: '',
      newExerciseTag: 'chest',
      newExerciseMuscles: ''
    })
  },

  hideAddModal() {
    this.setData({ showAddModal: false })
  },

  onNameInput(e) {
    this.setData({ newExerciseName: e.detail.value })
  },

  onMusclesInput(e) {
    this.setData({ newExerciseMuscles: e.detail.value })
  },

  selectNewTag(e) {
    this.setData({ newExerciseTag: e.currentTarget.dataset.tag })
  },

  addExercise() {
    const { newExerciseName, newExerciseTag, newExerciseMuscles } = this.data
    if (!newExerciseName.trim()) {
      wx.showToast({ title: '请输入动作名称', icon: 'none' })
      return
    }
    db.insertExercise({
      name: newExerciseName.trim(),
      tag: newExerciseTag,
      targetMuscles: newExerciseMuscles.trim()
    })
    this.setData({ showAddModal: false })
    this.loadExercises()
    wx.showToast({ title: '添加成功', icon: 'success' })
  },

  getTagDisplayName(tag) {
    return dataUtil.getTagDisplayName(tag)
  }
})
