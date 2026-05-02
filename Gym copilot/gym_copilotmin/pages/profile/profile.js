const db = require('../../utils/db.js')
const dataUtil = require('../../utils/data.js')

Page({
  data: {
    totalDuration: 0,
    totalSets: 0,
    avgFatigue: '0.0',
    topBodyPart: '-',
    workoutDays: 0
  },

  onLoad() {
    this.loadData()
  },

  onShow() {
    this.loadData()
  },

  loadData() {
    const records = db.getWorkoutRecords()
    
    let totalDuration = 0
    let totalSets = 0
    let totalFatigue = 0
    let fatigueCount = 0
    const bodyPartCount = {}
    const workoutDates = new Set()
    
    records.forEach(r => {
      totalDuration += r.durationMinutes || 0
      if (r.exerciseSets) {
        totalSets += r.exerciseSets.length
      }
      if (r.fatigueLevel) {
        totalFatigue += r.fatigueLevel
        fatigueCount++
      }
      if (r.bodyPart) {
        bodyPartCount[r.bodyPart] = (bodyPartCount[r.bodyPart] || 0) + 1
      }
      if (r.dateTime) {
        workoutDates.add(r.dateTime.split('T')[0])
      }
    })
    
    let topBodyPart = '-'
    let maxCount = 0
    for (const [part, count] of Object.entries(bodyPartCount)) {
      if (count > maxCount) {
        maxCount = count
        topBodyPart = dataUtil.getTagDisplayName(part)
      }
    }
    
    this.setData({
      totalDuration: Math.round(totalDuration),
      totalSets,
      avgFatigue: fatigueCount > 0 ? (totalFatigue / fatigueCount).toFixed(1) : '0.0',
      topBodyPart,
      workoutDays: workoutDates.size
    })
  },

  async exportData() {
    wx.showModal({
      title: '导出数据',
      content: '数据将复制到剪贴板，包含你的体重、体脂等个人数据。请勿在不信任的环境中粘贴。',
      success: async (res) => {
        if (res.confirm) {
          const data = db.exportAllData()
          try {
            await wx.setClipboardData({ data: JSON.stringify(data) })
            wx.showToast({ title: '已复制到剪贴板', icon: 'success' })
          } catch (e) {
            console.error('导出失败:', e)
          }
        }
      }
    })
  },

  async importData() {
    try {
      const clipboardData = await wx.getClipboardData()
      const data = JSON.parse(clipboardData.data)
      wx.showModal({
        title: '导入数据',
        content: '将覆盖所有现有数据，确定继续？',
        success: async (res) => {
          if (res.confirm) {
            db.importAllData(data)
            await wx.setClipboardData({ data: '' })
            wx.showToast({ title: '导入成功', icon: 'success' })
          }
        }
      })
    } catch (e) {
      wx.showToast({ title: '数据格式无效', icon: 'none' })
    }
  },

  navigateTo(e) {
    const url = e.currentTarget.dataset.url
    if (url) wx.navigateTo({ url })
  },

  showRestReminder() {
    wx.showToast({ title: '休息提醒已开启', icon: 'none' })
  },

  checkUpdate() {
    wx.showToast({ title: '已是最新版本', icon: 'none' })
  },

  showAbout() {
    wx.showModal({
      title: '关于 Gym Copilot',
      content: '版本: v1.0.0\n\n你的私人健身助手，帮助记录训练、制定计划、追踪进步。',
      showCancel: false
    })
  },

  clearAllData() {
    wx.showModal({
      title: '清除数据',
      content: '将删除所有训练记录和个人数据，内置动作不受影响。确定继续？',
      success: (res) => {
        if (res.confirm) {
          db.deleteAllRecords()
          this.loadData()
          wx.showToast({ title: '已清除', icon: 'success' })
        }
      }
    })
  }
})