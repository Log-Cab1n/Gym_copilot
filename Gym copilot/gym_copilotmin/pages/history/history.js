const db = require('../../utils/db.js')
const dataUtil = require('../../utils/data.js')

Page({
  data: {
    records: [],
    isLoading: true,
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
    const records = db.getWorkoutRecords()
    this.setData({ records: records, isLoading: false })
  },

  deleteRecord(e) {
    const id = e.currentTarget.dataset.id
    wx.showModal({
      title: '删除记录',
      content: '确定要删除这条训练记录吗？',
      success: (res) => {
        if (res.confirm) {
          db.deleteWorkoutRecord(id)
          this.loadData()
          wx.showToast({ title: '已删除', icon: 'success' })
        }
      }
    })
  },

  getTagDisplayName(tag) {
    return dataUtil.getTagDisplayName(tag)
  },

  getTagColor(tag) {
    return dataUtil.getTagColor(tag)
  },

  formatDate(dateTime) {
    const d = new Date(dateTime)
    return `${d.getMonth() + 1}/${d.getDate()} ${d.getHours().toString().padStart(2, '0')}:${d.getMinutes().toString().padStart(2, '0')}`
  }
})