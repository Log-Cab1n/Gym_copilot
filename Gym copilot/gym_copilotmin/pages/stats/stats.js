const db = require('../../utils/db.js')
const dataUtil = require('../../utils/data.js')

Page({
  data: {
    records: [],
    weeklyStats: [],
    monthlyStats: [],
    tagStats: [],
    totalWorkouts: 0,
    totalDuration: 0,
    currentStreak: 0,
    longestStreak: 0
  },

  onLoad() {
    this.loadStats()
  },

  onShow() {
    this.loadStats()
  },

  loadStats() {
    const records = db.getWorkoutRecords()
    this.setData({ records })
    this.calculateWeeklyStats(records)
    this.calculateMonthlyStats(records)
    this.calculateTagStats(records)
    this.calculateStreaks(records)
  },

  calculateWeeklyStats(records) {
    const stats = []
    const now = new Date()
    const maxDuration = Math.max(...records.map(r => r.durationMinutes), 120)
    for (let i = 6; i >= 0; i--) {
      const date = new Date(now)
      date.setDate(date.getDate() - i)
      const dateStr = date.toISOString().split('T')[0]
      const dayRecords = records.filter(r => r.dateTime.split('T')[0] === dateStr)
      const duration = dayRecords.reduce((sum, r) => sum + r.durationMinutes, 0)
      const barHeight = duration > 0 ? Math.min(duration / maxDuration * 100, 100) : 4
      stats.push({
        day: ['日', '一', '二', '三', '四', '五', '六'][date.getDay()],
        duration,
        hasWorkout: dayRecords.length > 0,
        barHeight
      })
    }
    this.setData({ weeklyStats: stats })
  },

  calculateMonthlyStats(records) {
    const monthMap = {}
    records.forEach(r => {
      const month = r.dateTime.substring(0, 7)
      if (!monthMap[month]) monthMap[month] = { count: 0, duration: 0 }
      monthMap[month].count++
      monthMap[month].duration += r.durationMinutes
    })
    const stats = Object.entries(monthMap)
      .sort((a, b) => b[0].localeCompare(a[0]))
      .slice(0, 6)
      .map(([month, data]) => ({
        month: month.substring(5) + '月',
        count: data.count,
        duration: data.duration
      }))
    this.setData({ monthlyStats: stats })
  },

  calculateTagStats(records) {
    const tagMap = {}
    records.forEach(r => {
      if (!tagMap[r.bodyPart]) tagMap[r.bodyPart] = { count: 0, duration: 0 }
      tagMap[r.bodyPart].count++
      tagMap[r.bodyPart].duration += r.durationMinutes
    })
    const stats = Object.entries(tagMap).map(([tag, data]) => ({
      tag,
      name: dataUtil.getTagDisplayName(tag),
      color: dataUtil.getTagColor(tag),
      count: data.count,
      duration: data.duration
    }))
    this.setData({ tagStats: stats })
  },

  calculateStreaks(records) {
    if (records.length === 0) {
      this.setData({ totalWorkouts: 0, totalDuration: 0, currentStreak: 0, longestStreak: 0 })
      return
    }

    const totalWorkouts = records.length
    const totalDuration = records.reduce((sum, r) => sum + r.durationMinutes, 0)

    const dates = [...new Set(records.map(r => r.dateTime.split('T')[0]))].sort()
    let currentStreak = 0
    let longestStreak = 0
    let tempStreak = 0

    const today = new Date().toISOString().split('T')[0]
    const yesterday = new Date(Date.now() - 86400000).toISOString().split('T')[0]

    for (let i = 0; i < dates.length; i++) {
      if (i === 0) {
        tempStreak = 1
      } else {
        const prev = new Date(dates[i - 1])
        const curr = new Date(dates[i])
        const diff = (curr - prev) / 86400000
        if (diff === 1) {
          tempStreak++
        } else {
          longestStreak = Math.max(longestStreak, tempStreak)
          tempStreak = 1
        }
      }
    }
    longestStreak = Math.max(longestStreak, tempStreak)

    if (dates.includes(today) || dates.includes(yesterday)) {
      currentStreak = tempStreak
    } else {
      currentStreak = 0
    }

    this.setData({ totalWorkouts, totalDuration, currentStreak, longestStreak })
  },

  getMaxDuration() {
    const max = Math.max(...this.data.weeklyStats.map(s => s.duration), 1)
    return max
  }
})