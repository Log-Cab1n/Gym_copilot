const db = require('../../utils/db.js')
const dataUtil = require('../../utils/data.js')

Page({
  data: {
    records: [],
    isLoading: true,
    weeklyWorkoutDays: 0,
    weeklyDuration: 0,
    todayRecords: [],
    pastRecords: [],
    tagNames: { chest: '胸', back: '背', legs: '腿', shoulders: '肩', arms: '臂', core: '腹' },
    tagColors: { chest: '#F8FAFC', back: '#64748B', legs: '#64748B', shoulders: '#A39E98', arms: '#4A4540', core: '#2A2520' }
  },

  onLoad() {
    this.loadData()
  },

  onShow() {
    this.loadData()
  },

  loadData() {
    try {
      const records = db.getWorkoutRecords()
      this.setData({ records, isLoading: false })
      this.calculateStats()
    } catch (e) {
      console.error('加载数据失败:', e)
      this.setData({ isLoading: false })
      wx.showToast({ title: '加载数据失败', icon: 'none' })
    }
  },

  calculateStats() {
    const { records } = this.data
    const now = new Date()
    const dayOfWeek = now.getDay()
    const mondayOffset = dayOfWeek === 0 ? -6 : 1 - dayOfWeek
    const startOfWeek = new Date(now)
    startOfWeek.setDate(now.getDate() + mondayOffset)
    startOfWeek.setHours(0, 0, 0, 0)

    const weekRecords = records.filter(r => new Date(r.dateTime) >= startOfWeek)
    const dates = new Set(weekRecords.map(r => r.dateTime.split('T')[0]))
    const weeklyDuration = weekRecords.reduce((sum, r) => sum + (r.durationMinutes || 0), 0)

    const today = now.toISOString().split('T')[0]
    const todayRecords = records.filter(r => r.dateTime.split('T')[0] === today)
    const pastRecords = records.filter(r => r.dateTime.split('T')[0] !== today)

    this.setData({
      weeklyWorkoutDays: dates.size,
      weeklyDuration,
      todayRecords,
      pastRecords
    })
  },

  onStartWorkout() {
    wx.navigateTo({ url: '/pages/workout/workout' })
  },

  onTemplates() {
    wx.navigateTo({ url: '/pages/templates/templates' })
  },

  onPullDownRefresh() {
    this.loadData()
    wx.stopPullDownRefresh()
  },

  getTagColor(tag) {
    return dataUtil.getTagColor(tag)
  },

  getTagDisplayName(tag) {
    return dataUtil.getTagDisplayName(tag)
  },

  formatDate(dateTime) {
    const d = new Date(dateTime)
    return `${(d.getMonth() + 1).toString().padStart(2, '0')}/${d.getDate().toString().padStart(2, '0')} ${d.getHours().toString().padStart(2, '0')}:${d.getMinutes().toString().padStart(2, '0')}`
  }
})