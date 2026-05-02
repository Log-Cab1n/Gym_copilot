const db = require('../../utils/db.js')
const dataUtil = require('../../utils/data.js')

Page({
  data: {
    plans: [],
    activePlan: null,
    showAddModal: false,
    planName: '',
    daysPerWeek: 4,
    startDate: '',
    endDate: '',
    workoutDays: ['胸', '背', '腿', '肩'],
    weekDays: ['周一', '周二', '周三', '周四', '周五', '周六', '周日'],
    selectedDays: [true, true, false, true, false, true, false],
    weekCompletion: [],
    remainingDays: 0
  },

  onLoad() {
    this.loadPlans()
  },

  onShow() {
    this.loadPlans()
  },

  loadPlans() {
    const plans = db.getWorkoutPlans()
    const activePlan = db.getActiveWorkoutPlan()
    const records = db.getWorkoutRecords()
    
    // 处理计划数据，添加进度和格式化日期
    const processedPlans = plans.map(plan => {
      const progress = this.calculateProgress(plan)
      const now = new Date()
      return {
        ...plan,
        progress,
        progressPercent: Math.round(progress * 100),
        dateRange: `${this.formatDate(plan.startDate)} - ${this.formatDate(plan.endDate)}`,
        _isActive: new Date(plan.startDate) <= now && new Date(plan.endDate) >= now
      }
    })
    
    let processedActive = null
    let remainingDays = 0
    if (activePlan) {
      const progress = this.calculateProgress(activePlan)
      processedActive = {
        ...activePlan,
        progress,
        progressPercent: Math.round(progress * 100),
        dateRange: `${this.formatDate(activePlan.startDate)} - ${this.formatDate(activePlan.endDate)}`
      }
      remainingDays = Math.max(0, Math.ceil((new Date(activePlan.endDate) - new Date()) / (1000 * 60 * 60 * 24)))
    }
    
    this.setData({ 
      plans: processedPlans, 
      activePlan: processedActive,
      weekCompletion: this.calculateWeekCompletion(records),
      remainingDays
    })
  },

  calculateProgress(plan) {
    if (!plan) return 0
    const totalDays = (new Date(plan.endDate) - new Date(plan.startDate)) / (1000 * 60 * 60 * 24)
    const passedDays = (new Date() - new Date(plan.startDate)) / (1000 * 60 * 60 * 24)
    if (totalDays <= 0) return 1
    return Math.min(Math.max(passedDays / totalDays, 0), 1)
  },

  calculateWeekCompletion(records) {
    const now = new Date()
    const dayOfWeek = now.getDay()
    const mondayOffset = dayOfWeek === 0 ? -6 : 1 - dayOfWeek
    const startOfWeek = new Date(now)
    startOfWeek.setDate(now.getDate() + mondayOffset)
    startOfWeek.setHours(0, 0, 0, 0)
    
    return Array.from({length: 7}, (_, i) => {
      const day = new Date(startOfWeek)
      day.setDate(startOfWeek.getDate() + i)
      const dayStr = `${day.getFullYear()}-${String(day.getMonth() + 1).padStart(2, '0')}-${String(day.getDate()).padStart(2, '0')}`
      return records.some(r => r.dateTime && r.dateTime.startsWith(dayStr))
    })
  },

  showAdd() {
    const now = new Date()
    const end = new Date(now)
    end.setDate(end.getDate() + 28)
    this.setData({
      showAddModal: true,
      startDate: now.toISOString().split('T')[0],
      endDate: end.toISOString().split('T')[0]
    })
  },

  hideAdd() {
    this.setData({ showAddModal: false })
  },

  onNameInput(e) {
    this.setData({ planName: e.detail.value })
  },

  onStartDateChange(e) {
    this.setData({ startDate: e.detail.value })
  },

  onEndDateChange(e) {
    this.setData({ endDate: e.detail.value })
  },

  selectDaysPerWeek(e) {
    this.setData({ daysPerWeek: e.currentTarget.dataset.days })
  },

  toggleDay(e) {
    const idx = e.currentTarget.dataset.index
    const selectedDays = [...this.data.selectedDays]
    selectedDays[idx] = !selectedDays[idx]
    this.setData({ selectedDays })
  },

  addPlan() {
    const { planName, startDate, endDate, daysPerWeek, selectedDays, weekDays } = this.data
    if (!planName.trim()) {
      wx.showToast({ title: '请输入计划名称', icon: 'none' })
      return
    }
    if (!startDate || !endDate) {
      wx.showToast({ title: '请选择日期', icon: 'none' })
      return
    }

    const days = weekDays.filter((_, i) => selectedDays[i])
    db.insertWorkoutPlan({
      name: planName,
      startDate,
      endDate,
      daysPerWeek,
      workoutDays: days.join(',')
    })

    this.setData({ showAddModal: false, planName: '' })
    this.loadPlans()
    wx.showToast({ title: '计划已创建', icon: 'success' })
  },

  deletePlan(e) {
    const id = e.currentTarget.dataset.id
    wx.showModal({
      title: '删除计划',
      content: '确定要删除这个训练计划吗？',
      success: (res) => {
        if (res.confirm) {
          db.deleteWorkoutPlan(id)
          this.loadPlans()
          wx.showToast({ title: '已删除', icon: 'success' })
        }
      }
    })
  },

  formatDate(dateStr) {
    if (!dateStr) return ''
    const d = new Date(dateStr)
    return `${d.getMonth() + 1}/${d.getDate()}`
  },

  isActive(plan) {
    const now = new Date()
    return new Date(plan.startDate) <= now && new Date(plan.endDate) >= now
  }
})
