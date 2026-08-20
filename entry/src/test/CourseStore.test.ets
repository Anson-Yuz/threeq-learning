import { describe, it, expect } from '@ohos/hypium';
import { CourseStore } from '../main/ets/stores/CourseStore';
import { CourseStage, ThreeQStep } from '../main/ets/models/CourseModel';

/**
 * 课程状态管理单元测试
 */
export default function courseStoreTest() {
  describe('CourseStore_Test', () => {
    it('should_create_new_course', 0, () => {
      const store = new CourseStore('test_user');
      const course = store.createCourse('如何学习ArkTS？', 'test_user');

      expect(course.id).assertContain('course_');
      expect(course.stage).assertEqual(CourseStage.CREATED);
      expect(course.step).assertEqual(ThreeQStep.QUESTION_1_MIND_MODEL);
      expect(course.totalProgress).assertEqual(0);
    });

    it('should_extract_title_from_question', 0, () => {
      const store = new CourseStore('test_user');
      const course = store.createCourse('如何快速掌握鸿蒙ArkTS开发？', 'test_user');
      expect(course.title.length).assertLarger(0);
    });

    it('should_transition_stage_correctly', 0, () => {
      const store = new CourseStore('test_user');
      const course = store.createCourse('测试问题', 'test_user');

      store.updateStep(course.id, ThreeQStep.QUESTION_2_DEBATE, 50);
      const updated = store.getCurrentCourse();

      expect(updated).assertNotNull();
      if (updated) {
        expect(updated.step).assertEqual(ThreeQStep.QUESTION_2_DEBATE);
        expect(updated.stage).assertEqual(CourseStage.ACTIVE);
      }
    });

    it('should_complete_course', 0, () => {
      const store = new CourseStore('test_user');
      const course = store.createCourse('测试问题', 'test_user');

      store.completeCourse(course.id);
      const updated = store.getCurrentCourse();

      expect(updated?.stage).assertEqual(CourseStage.COMPLETED);
      expect(updated?.totalProgress).assertEqual(100);
    });

    it('should_archive_course', 0, () => {
      const store = new CourseStore('test_user');
      const course = store.createCourse('测试问题', 'test_user');

      store.archiveCourse(course.id);
      const updated = store.getCurrentCourse();

      expect(updated?.stage).assertEqual(CourseStage.ARCHIVED);
    });

    it('should_sort_courses_by_updated_time', 0, () => {
      const store = new CourseStore('test_user');
      const c1 = store.createCourse('问题1', 'test_user');
      const c2 = store.createCourse('问题2', 'test_user');

      const active = store.getActiveCourses();
      expect(active.length).assertEqual(2);
      // c2 should be first because it was created last
      expect(active[0].id).assertEqual(c2.id);
    });
  });
}
