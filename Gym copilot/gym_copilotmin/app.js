App({
  onLaunch() {
    console.log('Gym Copilot 小程序启动')
    this.initStorage()
  },

  initStorage() {
    const keys = wx.getStorageInfoSync().keys
    if (!keys.includes('exercises')) {
      const data = require('./utils/data.js')
      const exercises = data.getBuiltInExercises()
      wx.setStorageSync('exercises', exercises)
    }
    if (!keys.includes('workout_records')) {
      wx.setStorageSync('workout_records', [])
    }
    if (!keys.includes('workout_plans')) {
      wx.setStorageSync('workout_plans', [])
    }
    if (!keys.includes('workout_templates')) {
      wx.setStorageSync('workout_templates', [])
    }
    if (!keys.includes('exercise_usage')) {
      wx.setStorageSync('exercise_usage', [])
    }
    if (!keys.includes('user_body_data')) {
      wx.setStorageSync('user_body_data', [])
    }
    if (!keys.includes('workout_in_progress')) {
      wx.setStorageSync('workout_in_progress', null)
    }
  },

  globalData: {
    userInfo: null
  }
})