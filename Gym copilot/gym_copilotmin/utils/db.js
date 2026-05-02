const dataUtil = require('./data.js')

let _idCounter = Date.now()

function _generateId() {
  return _idCounter++
}

function _getStorage(key) {
  try {
    return wx.getStorageSync(key) || []
  } catch (e) {
    return []
  }
}

function _setStorage(key, value) {
  wx.setStorageSync(key, value)
}

module.exports = {
  getExercises() {
    let exercises = _getStorage('exercises')
    if (!exercises || exercises.length === 0) {
      exercises = dataUtil.getBuiltInExercises()
      _setStorage('exercises', exercises)
    }
    return exercises.sort((a, b) => {
      if (a.tag !== b.tag) return a.tag.localeCompare(b.tag)
      return a.name.localeCompare(b.name)
    })
  },

  insertExercise(exercise) {
    const exercises = this.getExercises()
    exercise.id = _generateId()
    exercise.isBuiltIn = false
    exercises.push(exercise)
    _setStorage('exercises', exercises)
    return exercise.id
  },

  deleteExercise(id) {
    let exercises = this.getExercises()
    exercises = exercises.filter(e => e.id !== id || e.isBuiltIn)
    _setStorage('exercises', exercises)
    return 1
  },

  getWorkoutRecords() {
    const records = _getStorage('workout_records')
    records.forEach(r => {
      if (!r.exerciseSets) r.exerciseSets = []
    })
    return records.sort((a, b) => new Date(b.dateTime) - new Date(a.dateTime))
  },

  insertWorkoutRecord(record) {
    const records = this.getWorkoutRecords()
    record.id = _generateId()
    records.unshift(record)
    _setStorage('workout_records', records)
    if (record.exerciseSets) {
      record.exerciseSets.forEach(set => {
        this._updateExerciseUsage(set.exerciseId, set.exerciseName, record.dateTime)
      })
    }
    return record.id
  },

  _updateExerciseUsage(exerciseId, exerciseName, dateTime) {
    const usage = _getStorage('exercise_usage')
    const dateStr = dateTime.split('T')[0]
    const idx = usage.findIndex(u => u.exerciseId === exerciseId)
    if (idx === -1) {
      usage.push({ exerciseId, exerciseName, useCount: 1, lastUsedDate: dateStr })
    } else {
      usage[idx].useCount++
      usage[idx].lastUsedDate = dateStr
    }
    _setStorage('exercise_usage', usage)
  },

  deleteWorkoutRecord(id) {
    let records = this.getWorkoutRecords()
    records = records.filter(r => r.id !== id)
    _setStorage('workout_records', records)
    return 1
  },

  getWorkoutPlans() {
    return _getStorage('workout_plans').sort((a, b) => new Date(b.startDate) - new Date(a.startDate))
  },

  insertWorkoutPlan(plan) {
    const plans = this.getWorkoutPlans()
    plan.id = _generateId()
    plans.unshift(plan)
    _setStorage('workout_plans', plans)
    return plan.id
  },

  getActiveWorkoutPlan() {
    const now = new Date()
    const plans = this.getWorkoutPlans()
    return plans.find(p => new Date(p.startDate) <= now && new Date(p.endDate) >= now) || null
  },

  deleteWorkoutPlan(id) {
    let plans = this.getWorkoutPlans()
    plans = plans.filter(p => p.id !== id)
    _setStorage('workout_plans', plans)
    return 1
  },

  deleteAllRecords() {
    _setStorage('workout_records', [])
    _setStorage('workout_plans', [])
    _setStorage('exercise_usage', [])
    _setStorage('workout_templates', [])
    _setStorage('user_body_data', [])
    _setStorage('workout_in_progress', null)
    const exercises = dataUtil.getBuiltInExercises()
    _setStorage('exercises', exercises)
  },

  saveWorkoutInProgress({ startTime, bodyPart, fatigueLevel, sets }) {
    _setStorage('workout_in_progress', { startTime, bodyPart, fatigueLevel, sets })
  },

  getWorkoutInProgress() {
    return wx.getStorageSync('workout_in_progress') || null
  },

  clearWorkoutInProgress() {
    _setStorage('workout_in_progress', null)
  },

  saveWorkoutTemplate({ name, bodyPart, exercises }) {
    const templates = _getStorage('workout_templates')
    templates.unshift({
      id: _generateId(),
      name,
      bodyPart,
      exercisesJson: JSON.stringify(exercises),
      createdAt: new Date().toISOString()
    })
    _setStorage('workout_templates', templates)
    return templates[0].id
  },

  getWorkoutTemplates() {
    return _getStorage('workout_templates').sort((a, b) => new Date(b.createdAt) - new Date(a.createdAt))
  },

  deleteWorkoutTemplate(id) {
    let templates = _getStorage('workout_templates')
    templates = templates.filter(t => t.id !== id)
    _setStorage('workout_templates', templates)
    return 1
  },

  saveBodyData({ weight, height, bodyFat, muscleMass, recordDate }) {
    const bodyData = _getStorage('user_body_data')
    bodyData.unshift({
      id: _generateId(),
      weight,
      height,
      bodyFat,
      muscleMass,
      recordDate,
      createdAt: new Date().toISOString()
    })
    _setStorage('user_body_data', bodyData)
    return bodyData[0].id
  },

  getBodyData() {
    return _getStorage('user_body_data').sort((a, b) => new Date(b.recordDate) - new Date(a.recordDate))
  },

  deleteBodyData(id) {
    let bodyData = _getStorage('user_body_data')
    bodyData = bodyData.filter(d => d.id !== id)
    _setStorage('user_body_data', bodyData)
    return 1
  },

  exportAllData() {
    return {
      version: 1,
      exportTime: new Date().toISOString(),
      exercises: this.getExercises().filter(e => !e.isBuiltIn),
      exercise_usage: _getStorage('exercise_usage'),
      workout_records: this.getWorkoutRecords(),
      workout_plans: _getStorage('workout_plans'),
      workout_templates: this.getWorkoutTemplates(),
      user_body_data: this.getBodyData()
    }
  },

  importAllData(data) {
    if (data.exercises) {
      const builtIn = dataUtil.getBuiltInExercises()
      const custom = data.exercises.filter(e => !e.isBuiltIn)
      _setStorage('exercises', [...builtIn, ...custom])
    }
    if (data.exercise_usage) _setStorage('exercise_usage', data.exercise_usage)
    if (data.workout_records) _setStorage('workout_records', data.workout_records)
    if (data.workout_plans) _setStorage('workout_plans', data.workout_plans)
    if (data.workout_templates) _setStorage('workout_templates', data.workout_templates)
    if (data.user_body_data) _setStorage('user_body_data', data.user_body_data)
  }
}