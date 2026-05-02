const db = require('../../utils/db.js')

Page({
  data: {
    bodyData: [],
    latestData: null,
    showAddModal: false,
    weight: '',
    height: '',
    bodyFat: '',
    muscleMass: '',
    recordDate: new Date().toISOString().split('T')[0]
  },

  onLoad() {
    this.loadData()
  },

  onShow() {
    this.loadData()
  },

  loadData() {
    const bodyData = db.getBodyData()
    const latestData = bodyData.length > 0 ? bodyData[0] : null
    this.setData({ bodyData, latestData })
  },

  showAdd() {
    this.setData({
      showAddModal: true,
      weight: '',
      height: '',
      bodyFat: '',
      muscleMass: '',
      recordDate: new Date().toISOString().split('T')[0]
    })
  },

  hideAdd() {
    this.setData({ showAddModal: false })
  },

  onWeightInput(e) {
    this.setData({ weight: e.detail.value })
  },

  onHeightInput(e) {
    this.setData({ height: e.detail.value })
  },

  onBodyFatInput(e) {
    this.setData({ bodyFat: e.detail.value })
  },

  onMuscleMassInput(e) {
    this.setData({ muscleMass: e.detail.value })
  },

  onDateChange(e) {
    this.setData({ recordDate: e.detail.value })
  },

  saveBodyData() {
    db.saveBodyData({
      weight: this.data.weight ? parseFloat(this.data.weight) : null,
      height: this.data.height ? parseFloat(this.data.height) : null,
      bodyFat: this.data.bodyFat ? parseFloat(this.data.bodyFat) : null,
      muscleMass: this.data.muscleMass ? parseFloat(this.data.muscleMass) : null,
      recordDate: this.data.recordDate
    })
    this.setData({ showAddModal: false })
    this.loadData()
    wx.showToast({ title: '数据已保存', icon: 'success' })
  },

  deleteBodyData(e) {
    const id = e.currentTarget.dataset.id
    wx.showModal({
      title: '删除记录',
      content: '确定要删除这条身体数据吗？',
      success: (res) => {
        if (res.confirm) {
          db.deleteBodyData(id)
          this.loadData()
          wx.showToast({ title: '已删除', icon: 'success' })
        }
      }
    })
  }
})
