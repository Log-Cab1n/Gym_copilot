import '../models/exercise.dart';

class ExerciseData {
  static List<Exercise> getBuiltInExercises() {
    return [
      // 胸
      Exercise(
          name: '杠铃卧推',
          tag: 'chest',
          isBuiltIn: true,
          targetMuscles: '胸大肌、肩前束、肱三头肌'),
      Exercise(
          name: '哑铃卧推',
          tag: 'chest',
          isBuiltIn: true,
          targetMuscles: '胸大肌、肩前束、肱三头肌'),
      Exercise(
          name: '史密斯机卧推',
          tag: 'chest',
          isBuiltIn: true,
          targetMuscles: '胸大肌、肩前束、肱三头肌'),
      Exercise(
          name: '哑铃飞鸟',
          tag: 'chest',
          isBuiltIn: true,
          targetMuscles: '胸大肌（中缝）'),
      Exercise(
          name: '龙门架夹胸',
          tag: 'chest',
          isBuiltIn: true,
          targetMuscles: '胸大肌（下沿）'),
      Exercise(
          name: '俯卧撑',
          tag: 'chest',
          isBuiltIn: true,
          targetMuscles: '胸大肌、肩前束、肱三头肌'),
      Exercise(
          name: '双杠臂屈伸',
          tag: 'chest',
          isBuiltIn: true,
          targetMuscles: '胸大肌（下沿）、肱三头肌'),
      Exercise(
          name: '蝴蝶机夹胸',
          tag: 'chest',
          isBuiltIn: true,
          targetMuscles: '胸大肌（中缝）'),
      // 背
      Exercise(
          name: '引体向上',
          tag: 'back',
          isBuiltIn: true,
          targetMuscles: '背阔肌、肱二头肌'),
      Exercise(
          name: '高位下拉',
          tag: 'back',
          isBuiltIn: true,
          targetMuscles: '背阔肌、肱二头肌'),
      Exercise(
          name: '坐姿划船',
          tag: 'back',
          isBuiltIn: true,
          targetMuscles: '背阔肌、菱形肌、斜方肌中下束'),
      Exercise(
          name: '杠铃划船',
          tag: 'back',
          isBuiltIn: true,
          targetMuscles: '背阔肌、菱形肌、斜方肌'),
      Exercise(
          name: '哑铃划船',
          tag: 'back',
          isBuiltIn: true,
          targetMuscles: '背阔肌、菱形肌'),
      Exercise(
          name: '直臂下压',
          tag: 'back',
          isBuiltIn: true,
          targetMuscles: '背阔肌'),
      Exercise(
          name: '硬拉',
          tag: 'back',
          isBuiltIn: true,
          targetMuscles: '竖脊肌、臀大肌、腘绳肌'),
      Exercise(
          name: 'TRX划船',
          tag: 'back',
          isBuiltIn: true,
          targetMuscles: '背阔肌、菱形肌、肱二头肌'),
      // 腿
      Exercise(
          name: '杠铃深蹲',
          tag: 'legs',
          isBuiltIn: true,
          targetMuscles: '股四头肌、臀大肌、腘绳肌'),
      Exercise(
          name: '哑铃深蹲',
          tag: 'legs',
          isBuiltIn: true,
          targetMuscles: '股四头肌、臀大肌'),
      Exercise(
          name: '腿举',
          tag: 'legs',
          isBuiltIn: true,
          targetMuscles: '股四头肌、臀大肌'),
      Exercise(
          name: '腿弯举',
          tag: 'legs',
          isBuiltIn: true,
          targetMuscles: '腘绳肌'),
      Exercise(
          name: '腿伸展',
          tag: 'legs',
          isBuiltIn: true,
          targetMuscles: '股四头肌'),
      Exercise(
          name: '罗马尼亚硬拉',
          tag: 'legs',
          isBuiltIn: true,
          targetMuscles: '腘绳肌、臀大肌、竖脊肌'),
      Exercise(
          name: '弓步蹲',
          tag: 'legs',
          isBuiltIn: true,
          targetMuscles: '股四头肌、臀大肌'),
      Exercise(
          name: '保加利亚深蹲',
          tag: 'legs',
          isBuiltIn: true,
          targetMuscles: '股四头肌、臀大肌'),
      Exercise(
          name: '臀推',
          tag: 'legs',
          isBuiltIn: true,
          targetMuscles: '臀大肌、腘绳肌'),
      // 肩
      Exercise(
          name: '哑铃推举',
          tag: 'shoulders',
          isBuiltIn: true,
          targetMuscles: '三角肌前束、中束、肱三头肌'),
      Exercise(
          name: '杠铃推举',
          tag: 'shoulders',
          isBuiltIn: true,
          targetMuscles: '三角肌前束、中束、肱三头肌'),
      Exercise(
          name: '侧平举',
          tag: 'shoulders',
          isBuiltIn: true,
          targetMuscles: '三角肌中束'),
      Exercise(
          name: '前平举',
          tag: 'shoulders',
          isBuiltIn: true,
          targetMuscles: '三角肌前束'),
      Exercise(
          name: '俯身飞鸟',
          tag: 'shoulders',
          isBuiltIn: true,
          targetMuscles: '三角肌后束'),
      Exercise(
          name: '面拉',
          tag: 'shoulders',
          isBuiltIn: true,
          targetMuscles: '三角肌后束、菱形肌'),
      Exercise(
          name: '阿诺德推举',
          tag: 'shoulders',
          isBuiltIn: true,
          targetMuscles: '三角肌前束、中束、肱三头肌'),
      // 臂
      Exercise(
          name: '杠铃弯举',
          tag: 'arms',
          isBuiltIn: true,
          targetMuscles: '肱二头肌'),
      Exercise(
          name: '哑铃弯举',
          tag: 'arms',
          isBuiltIn: true,
          targetMuscles: '肱二头肌'),
      Exercise(
          name: '锤式弯举',
          tag: 'arms',
          isBuiltIn: true,
          targetMuscles: '肱桡肌、肱二头肌'),
      Exercise(
          name: '集中弯举',
          tag: 'arms',
          isBuiltIn: true,
          targetMuscles: '肱二头肌（短头）'),
      Exercise(
          name: '绳索下压',
          tag: 'arms',
          isBuiltIn: true,
          targetMuscles: '肱三头肌'),
      Exercise(
          name: '哑铃臂屈伸',
          tag: 'arms',
          isBuiltIn: true,
          targetMuscles: '肱三头肌'),
      Exercise(
          name: '双杠臂屈伸',
          tag: 'arms',
          isBuiltIn: true,
          targetMuscles: '肱三头肌、胸大肌（下沿）'),
      Exercise(
          name: '过头臂屈伸',
          tag: 'arms',
          isBuiltIn: true,
          targetMuscles: '肱三头肌（长头）'),
      // 腹
      Exercise(
          name: '卷腹',
          tag: 'core',
          isBuiltIn: true,
          targetMuscles: '腹直肌（上段）'),
      Exercise(
          name: '平板支撑',
          tag: 'core',
          isBuiltIn: true,
          targetMuscles: '腹横肌、核心肌群'),
      Exercise(
          name: '俄罗斯转体',
          tag: 'core',
          isBuiltIn: true,
          targetMuscles: '腹外斜肌、腹内斜肌'),
      Exercise(
          name: '悬垂举腿',
          tag: 'core',
          isBuiltIn: true,
          targetMuscles: '腹直肌（下段）'),
      Exercise(
          name: '山羊挺身',
          tag: 'core',
          isBuiltIn: true,
          targetMuscles: '竖脊肌、臀大肌'),
      Exercise(
          name: '死虫式',
          tag: 'core',
          isBuiltIn: true,
          targetMuscles: '腹横肌、核心稳定性'),
      Exercise(
          name: '鸟狗式',
          tag: 'core',
          isBuiltIn: true,
          targetMuscles: '竖脊肌、腹横肌、臀大肌'),
      Exercise(
          name: '侧支撑',
          tag: 'core',
          isBuiltIn: true,
          targetMuscles: '腹外斜肌、腹内斜肌'),
    ];
  }

  static String getTagDisplayName(String tag) {
    final Map<String, String> tagNames = {
      'chest': '胸',
      'back': '背',
      'legs': '腿',
      'shoulders': '肩',
      'arms': '臂',
      'core': '腹',
    };
    return tagNames[tag] ?? tag;
  }

  static List<String> getAllTags() {
    return ['chest', 'back', 'legs', 'shoulders', 'arms', 'core'];
  }
}
