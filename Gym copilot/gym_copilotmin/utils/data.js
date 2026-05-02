const builtInExercises = [
  { id: 1, name: '杠铃卧推', tag: 'chest', isBuiltIn: true, targetMuscles: '胸大肌、肩前束、肱三头肌' },
  { id: 2, name: '哑铃卧推', tag: 'chest', isBuiltIn: true, targetMuscles: '胸大肌、肩前束、肱三头肌' },
  { id: 3, name: '史密斯机卧推', tag: 'chest', isBuiltIn: true, targetMuscles: '胸大肌、肩前束、肱三头肌' },
  { id: 4, name: '哑铃飞鸟', tag: 'chest', isBuiltIn: true, targetMuscles: '胸大肌（中缝）' },
  { id: 5, name: '龙门架夹胸', tag: 'chest', isBuiltIn: true, targetMuscles: '胸大肌（下沿）' },
  { id: 6, name: '俯卧撑', tag: 'chest', isBuiltIn: true, targetMuscles: '胸大肌、肩前束、肱三头肌' },
  { id: 7, name: '双杠臂屈伸', tag: 'chest', isBuiltIn: true, targetMuscles: '胸大肌（下沿）、肱三头肌' },
  { id: 8, name: '蝴蝶机夹胸', tag: 'chest', isBuiltIn: true, targetMuscles: '胸大肌（中缝）' },
  { id: 9, name: '引体向上', tag: 'back', isBuiltIn: true, targetMuscles: '背阔肌、肱二头肌' },
  { id: 10, name: '高位下拉', tag: 'back', isBuiltIn: true, targetMuscles: '背阔肌、肱二头肌' },
  { id: 11, name: '坐姿划船', tag: 'back', isBuiltIn: true, targetMuscles: '背阔肌、菱形肌、斜方肌中下束' },
  { id: 12, name: '杠铃划船', tag: 'back', isBuiltIn: true, targetMuscles: '背阔肌、菱形肌、斜方肌' },
  { id: 13, name: '哑铃划船', tag: 'back', isBuiltIn: true, targetMuscles: '背阔肌、菱形肌' },
  { id: 14, name: '直臂下压', tag: 'back', isBuiltIn: true, targetMuscles: '背阔肌' },
  { id: 15, name: '硬拉', tag: 'back', isBuiltIn: true, targetMuscles: '竖脊肌、臀大肌、腘绳肌' },
  { id: 16, name: 'TRX划船', tag: 'back', isBuiltIn: true, targetMuscles: '背阔肌、菱形肌、肱二头肌' },
  { id: 17, name: '杠铃深蹲', tag: 'legs', isBuiltIn: true, targetMuscles: '股四头肌、臀大肌、腘绳肌' },
  { id: 18, name: '哑铃深蹲', tag: 'legs', isBuiltIn: true, targetMuscles: '股四头肌、臀大肌' },
  { id: 19, name: '腿举', tag: 'legs', isBuiltIn: true, targetMuscles: '股四头肌、臀大肌' },
  { id: 20, name: '腿弯举', tag: 'legs', isBuiltIn: true, targetMuscles: '腘绳肌' },
  { id: 21, name: '腿伸展', tag: 'legs', isBuiltIn: true, targetMuscles: '股四头肌' },
  { id: 22, name: '罗马尼亚硬拉', tag: 'legs', isBuiltIn: true, targetMuscles: '腘绳肌、臀大肌、竖脊肌' },
  { id: 23, name: '弓步蹲', tag: 'legs', isBuiltIn: true, targetMuscles: '股四头肌、臀大肌' },
  { id: 24, name: '保加利亚深蹲', tag: 'legs', isBuiltIn: true, targetMuscles: '股四头肌、臀大肌' },
  { id: 25, name: '臀推', tag: 'legs', isBuiltIn: true, targetMuscles: '臀大肌、腘绳肌' },
  { id: 26, name: '哑铃推举', tag: 'shoulders', isBuiltIn: true, targetMuscles: '三角肌前束、中束、肱三头肌' },
  { id: 27, name: '杠铃推举', tag: 'shoulders', isBuiltIn: true, targetMuscles: '三角肌前束、中束、肱三头肌' },
  { id: 28, name: '侧平举', tag: 'shoulders', isBuiltIn: true, targetMuscles: '三角肌中束' },
  { id: 29, name: '前平举', tag: 'shoulders', isBuiltIn: true, targetMuscles: '三角肌前束' },
  { id: 30, name: '俯身飞鸟', tag: 'shoulders', isBuiltIn: true, targetMuscles: '三角肌后束' },
  { id: 31, name: '面拉', tag: 'shoulders', isBuiltIn: true, targetMuscles: '三角肌后束、菱形肌' },
  { id: 32, name: '阿诺德推举', tag: 'shoulders', isBuiltIn: true, targetMuscles: '三角肌前束、中束、肱三头肌' },
  { id: 33, name: '杠铃弯举', tag: 'arms', isBuiltIn: true, targetMuscles: '肱二头肌' },
  { id: 34, name: '哑铃弯举', tag: 'arms', isBuiltIn: true, targetMuscles: '肱二头肌' },
  { id: 35, name: '锤式弯举', tag: 'arms', isBuiltIn: true, targetMuscles: '肱桡肌、肱二头肌' },
  { id: 36, name: '集中弯举', tag: 'arms', isBuiltIn: true, targetMuscles: '肱二头肌（短头）' },
  { id: 37, name: '绳索下压', tag: 'arms', isBuiltIn: true, targetMuscles: '肱三头肌' },
  { id: 38, name: '哑铃臂屈伸', tag: 'arms', isBuiltIn: true, targetMuscles: '肱三头肌' },
  { id: 39, name: '双杠臂屈伸', tag: 'arms', isBuiltIn: true, targetMuscles: '肱三头肌、胸大肌（下沿）' },
  { id: 40, name: '过头臂屈伸', tag: 'arms', isBuiltIn: true, targetMuscles: '肱三头肌（长头）' },
  { id: 41, name: '卷腹', tag: 'core', isBuiltIn: true, targetMuscles: '腹直肌（上段）' },
  { id: 42, name: '平板支撑', tag: 'core', isBuiltIn: true, targetMuscles: '腹横肌、核心肌群' },
  { id: 43, name: '俄罗斯转体', tag: 'core', isBuiltIn: true, targetMuscles: '腹外斜肌、腹内斜肌' },
  { id: 44, name: '悬垂举腿', tag: 'core', isBuiltIn: true, targetMuscles: '腹直肌（下段）' },
  { id: 45, name: '山羊挺身', tag: 'core', isBuiltIn: true, targetMuscles: '竖脊肌、臀大肌' },
  { id: 46, name: '死虫式', tag: 'core', isBuiltIn: true, targetMuscles: '腹横肌、核心稳定性' },
  { id: 47, name: '鸟狗式', tag: 'core', isBuiltIn: true, targetMuscles: '竖脊肌、腹横肌、臀大肌' },
  { id: 48, name: '侧支撑', tag: 'core', isBuiltIn: true, targetMuscles: '腹外斜肌、腹内斜肌' }
]

function getBuiltInExercises() {
  return JSON.parse(JSON.stringify(builtInExercises))
}

function getTagDisplayName(tag) {
  const tagNames = {
    chest: '胸',
    back: '背',
    legs: '腿',
    shoulders: '肩',
    arms: '臂',
    core: '腹'
  }
  return tagNames[tag] || tag
}

function getAllTags() {
  return ['chest', 'back', 'legs', 'shoulders', 'arms', 'core']
}

function getTagColor(tag) {
  const colors = {
    chest: '#F8FAFC',
    back: '#64748B',
    legs: '#64748B',
    shoulders: '#A39E98',
    arms: '#4A4540',
    core: '#2A2520'
  }
  return colors[tag] || '#64748B'
}

module.exports = {
  getBuiltInExercises,
  getTagDisplayName,
  getAllTags,
  getTagColor
}