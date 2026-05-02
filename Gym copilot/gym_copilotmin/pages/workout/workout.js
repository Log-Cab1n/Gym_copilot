const db = require('../../utils/db.js')
const dataUtil = require('../../utils/data.js')

let timerInterval = null
let saveInterval = null
let pulseAnimation = null
let glowAnimation = null

Page({
  data: {
    selectedBodyPart: null,
    exercises: [],
    sets: [],
    fatigueLevel: 5,
    startTime: null,
    isTimerRunning: false,
    elapsedMinutes: 0,
    elapsedSeconds: 0,
    isUsingTemplate: false,
    isSaving: false,
    statusBarHeight: 0,

    // 底部弹窗
    showAddModal: false,
    selectedExercise: null,
    weight: '',
    reps: '',
    setsCount: '1',
    availableExercises: [],

    // 编辑弹窗
    showEditModal: false,
    editingSet: null,
    editingIndex: -1,
    editWeight: '',
    editReps: '',

    // 完成弹窗
    showSummaryModal: false,
    summaryData: null,

    // 动画
    pulseScale: 1,
    glowOpacity: 0,
    glowStyle: '',

    // 放弃弹窗
    showDiscardModal: false,

    bodyParts: [
      { key: 'chest', name: '胸' },
      { key: 'back', name: '背' },
      { key: 'legs', name: '腿' },
      { key: 'shoulders', name: '肩' },
      { key: 'arms', name: '臂' },
      { key: 'core', name: '腹' }
    ]
  },

  onLoad(options) {
    const systemInfo = wx.getSystemInfoSync()
    const exercises = db.getExercises()
    this.setData({
      exercises,
      startTime: new Date().toISOString(),
      statusBarHeight: systemInfo.statusBarHeight
    })

    wx.enableAlertBeforeUnload({
      message: '确定要退出训练吗？未保存的训练将丢失。'
    })

    if (options.template) {
      try {
        const template = JSON.parse(decodeURIComponent(options.template))
        this.applyTemplate(template)
      } catch (e) {
        console.error('模板解析失败:', e)
      }
    }

    this.restoreWorkoutState()
    this.startPulseAnimation()
  },

  onShow() {
    if (this.data.startTime) {
      this.updateTimer()
    }
  },

  onHide() {
    this.persistWorkoutState()
    this.stopAnimations()
  },

  onUnload() {
    this.stopTimer()
    this.stopAnimations()
  },

  // 脉冲动画
  startPulseAnimation() {
    if (this.data.isTimerRunning) return
    let growing = true
    pulseAnimation = setInterval(() => {
      let scale = this.data.pulseScale
      if (growing) {
        scale += 0.003
        if (scale >= 1.08) growing = false
      } else {
        scale -= 0.003
        if (scale <= 1.0) growing = true
      }
      this.setData({ pulseScale: scale })
    }, 30)
  },

  // 发光动画
  startGlowAnimation() {
    let growing = true
    glowAnimation = setInterval(() => {
      let opacity = this.data.glowOpacity
      if (growing) {
        opacity += 0.02
        if (opacity >= 1) growing = false
      } else {
        opacity -= 0.02
        if (opacity <= 0) growing = true
      }
      const glowStyle = `opacity: ${0.5 + 0.5 * opacity}; box-shadow: 0 0 ${Math.round(2 * opacity)}rpx rgba(232, 228, 225, ${0.5 * opacity});`
      this.setData({ glowOpacity: opacity, glowStyle })
    }, 40)
  },

  stopAnimations() {
    if (pulseAnimation) {
      clearInterval(pulseAnimation)
      pulseAnimation = null
    }
    if (glowAnimation) {
      clearInterval(glowAnimation)
      glowAnimation = null
    }
  },

  applyTemplate(template) {
    const sets = []
    let setNumber = 1
    template.exercises.forEach(ex => {
      const count = ex.sets || 1
      for (let i = 0; i < count; i++) {
        sets.push({
          exerciseId: ex.exerciseId,
          exerciseName: ex.exerciseName,
          exerciseTag: ex.exerciseTag,
          weight: ex.weight || 0,
          reps: ex.reps || 0,
          setNumber: setNumber++
        })
      }
    })
    this.setData({
      selectedBodyPart: template.bodyPart,
      sets,
      isUsingTemplate: true
    })
    this.startTimer()
  },

  restoreWorkoutState() {
    const saved = db.getWorkoutInProgress()
    if (saved && saved.sets && saved.sets.length > 0) {
      this.setData({
        startTime: saved.startTime,
        selectedBodyPart: saved.bodyPart,
        fatigueLevel: saved.fatigueLevel,
        sets: saved.sets,
        isTimerRunning: true
      })
      this.startTimer(false)
      wx.showToast({ title: '已恢复训练', icon: 'none' })
    }
  },

  persistWorkoutState() {
    const { startTime, selectedBodyPart, fatigueLevel, sets } = this.data
    if (sets.length > 0) {
      db.saveWorkoutInProgress({
        startTime,
        bodyPart: selectedBodyPart,
        fatigueLevel,
        sets
      })
    }
  },

  startTimer(resetStartTime = true) {
    if (timerInterval) return

    const update = () => {
      if (resetStartTime) {
        this.setData({
          startTime: new Date().toISOString(),
          isTimerRunning: true
        })
      } else {
        this.setData({ isTimerRunning: true })
      }
    }
    update()

    // 停止脉冲，启动发光
    this.stopAnimations()
    this.setData({ pulseScale: 1 })
    this.startGlowAnimation()

    timerInterval = setInterval(() => {
      this.updateTimer()
    }, 1000)
    saveInterval = setInterval(() => {
      this.persistWorkoutState()
    }, 10000)
  },

  updateTimer() {
    if (!this.data.startTime) return
    const start = new Date(this.data.startTime)
    const now = new Date()
    const diff = Math.floor((now - start) / 1000)
    this.setData({
      elapsedMinutes: Math.floor(diff / 60),
      elapsedSeconds: diff % 60
    })
  },

  stopTimer() {
    if (timerInterval) {
      clearInterval(timerInterval)
      timerInterval = null
    }
    if (saveInterval) {
      clearInterval(saveInterval)
      saveInterval = null
    }
  },

  // 选择训练部位
  selectBodyPart(e) {
    const tag = e.currentTarget.dataset.tag
    const selected = this.data.selectedBodyPart === tag ? null : tag
    this.setData({ selectedBodyPart: selected })
  },

  // 打开添加动作弹窗
  showAddModal() {
    if (!this.data.selectedBodyPart) {
      wx.showToast({ title: '请先选择训练部位', icon: 'none' })
      return
    }
    const availableExercises = this.data.exercises.filter(
      e => e.tag === this.data.selectedBodyPart
    )
    this.setData({
      showAddModal: true,
      availableExercises,
      selectedExercise: availableExercises.length > 0 ? availableExercises[0] : null,
      weight: '',
      reps: '',
      setsCount: '1'
    })
  },

  hideAddModal() {
    this.setData({ showAddModal: false })
  },

  // 选择动作（picker方式）
  onExerciseChange(e) {
    const index = parseInt(e.detail.value)
    this.setData({ selectedExercise: this.data.availableExercises[index] })
  },

  onWeightInput(e) {
    this.setData({ weight: e.detail.value })
  },

  onRepsInput(e) {
    this.setData({ reps: e.detail.value })
  },

  onSetsCountInput(e) {
    this.setData({ setsCount: e.detail.value })
  },

  addSet() {
    const { selectedExercise, weight, reps, setsCount, sets } = this.data
    if (!selectedExercise) {
      wx.showToast({ title: '请选择动作', icon: 'none' })
      return
    }
    if (!weight || !reps) {
      wx.showToast({ title: '请填写重量和次数', icon: 'none' })
      return
    }

    const count = parseInt(setsCount) || 1
    const newSets = [...sets]
    const startNumber = newSets.length + 1

    for (let i = 0; i < count; i++) {
      newSets.push({
        exerciseId: selectedExercise.id,
        exerciseName: selectedExercise.name,
        exerciseTag: selectedExercise.tag,
        weight: parseFloat(weight),
        reps: parseInt(reps),
        setNumber: startNumber + i
      })
    }

    this.setData({
      sets: newSets,
      weight: '',
      reps: '',
      setsCount: '1',
      showAddModal: false
    })

    if (!this.data.isTimerRunning) {
      this.startTimer()
    }
    this.persistWorkoutState()
  },

  // 编辑模板动作
  editSet(e) {
    const index = e.currentTarget.dataset.index
    const set = this.data.sets[index]
    // 只有模板动作（weight和reps都为0）才允许编辑
    if (set.weight !== 0 || set.reps !== 0) {
      wx.showToast({ title: '只有模板动作可编辑', icon: 'none' })
      return
    }

    this.setData({
      showEditModal: true,
      editingSet: set,
      editingIndex: index,
      editWeight: set.weight ? String(set.weight) : '',
      editReps: set.reps ? String(set.reps) : ''
    })
  },

  hideEditModal() {
    this.setData({ showEditModal: false })
  },

  onEditWeightInput(e) {
    this.setData({ editWeight: e.detail.value })
  },

  onEditRepsInput(e) {
    this.setData({ editReps: e.detail.value })
  },

  saveEditSet() {
    const { editingIndex, editWeight, editReps, sets } = this.data
    if (!editWeight || !editReps) {
      wx.showToast({ title: '请填写重量和次数', icon: 'none' })
      return
    }

    const updatedSets = [...sets]
    updatedSets[editingIndex] = {
      ...updatedSets[editingIndex],
      weight: parseFloat(editWeight),
      reps: parseInt(editReps)
    }

    this.setData({
      sets: updatedSets,
      showEditModal: false
    })
    this.persistWorkoutState()
  },

  removeSet(e) {
    const index = e.currentTarget.dataset.index
    const sets = this.data.sets.filter((_, i) => i !== index)
    sets.forEach((set, i) => { set.setNumber = i + 1 })
    this.setData({ sets })
    this.persistWorkoutState()
  },

  // 疲劳度
  onFatigueChange(e) {
    this.setData({ fatigueLevel: parseInt(e.detail.value) })
  },

  // 完成训练
  finishWorkout() {
    const { sets, selectedBodyPart, fatigueLevel, startTime, isUsingTemplate } = this.data

    if (!selectedBodyPart) {
      wx.showToast({ title: '请选择训练部位', icon: 'none' })
      return
    }

    if (sets.length === 0) {
      if (isUsingTemplate) {
        wx.showModal({
          title: '结束训练？',
          content: '您尚未记录任何动作，确定要结束本次训练吗？',
          confirmText: '结束训练',
          cancelText: '继续训练',
          success: (res) => {
            if (res.confirm) {
              this._saveWorkout(true)
            }
          }
        })
        return
      } else {
        wx.showToast({ title: '请添加至少一个动作', icon: 'none' })
        return
      }
    }

    this.stopTimer()
    const start = new Date(startTime)
    const now = new Date()
    const durationMinutes = Math.floor((now - start) / 60000)

    this.setData({
      showSummaryModal: true,
      summaryData: {
        bodyPart: dataUtil.getTagDisplayName(selectedBodyPart),
        duration: Math.max(durationMinutes, 1),
        setsCount: sets.length,
        fatigueLevel
      }
    })
  },

  hideSummaryModal() {
    this.setData({ showSummaryModal: false })
    // 恢复计时器（避免重复启动）
    if (this.data.sets.length > 0 && !timerInterval) {
      timerInterval = setInterval(() => {
        this.updateTimer()
      }, 1000)
      saveInterval = setInterval(() => {
        this.persistWorkoutState()
      }, 10000)
    }
  },

  confirmFinishWorkout() {
    this._saveWorkout(false)
  },

  _saveWorkout(isEmpty) {
    const { sets, selectedBodyPart, fatigueLevel, startTime } = this.data
    const start = new Date(startTime)
    const now = new Date()
    const durationMinutes = Math.floor((now - start) / 60000)

    this.setData({ isSaving: true, showSummaryModal: false })

    const record = {
      dateTime: now.toISOString(),
      bodyPart: selectedBodyPart || 'chest',
      durationMinutes: Math.max(durationMinutes, 1),
      fatigueLevel,
      exerciseSets: isEmpty ? [] : sets
    }

    db.insertWorkoutRecord(record)
    db.clearWorkoutInProgress()
    this.stopTimer()
    wx.disableAlertBeforeUnload()

    wx.showToast({ title: '训练记录已保存', icon: 'success' })
    setTimeout(() => {
      wx.navigateBack()
    }, 1500)
  },

  // 放弃训练
  showDiscardDialog() {
    if (this.data.sets.length === 0) {
      db.clearWorkoutInProgress()
      this.stopTimer()
      wx.disableAlertBeforeUnload()
      wx.navigateBack()
      return
    }
    this.setData({ showDiscardModal: true })
  },

  hideDiscardModal() {
    this.setData({ showDiscardModal: false })
  },

  confirmDiscard() {
    db.clearWorkoutInProgress()
    this.stopTimer()
    this.setData({ showDiscardModal: false })
    wx.disableAlertBeforeUnload()
    wx.navigateBack()
  },

  getTagDisplayName(tag) {
    return dataUtil.getTagDisplayName(tag)
  },

  formatTime(minutes, seconds) {
    return `${minutes.toString().padStart(2, '0')}:${seconds.toString().padStart(2, '0')}`
  },

  isTemplateSet(set) {
    return set.weight === 0 && set.reps === 0
  }
})