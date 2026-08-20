import router from '@ohos.router';
import { CourseStore } from '../stores/CourseStore';
import { CourseCard } from '../components/CourseCard';
import { CourseModel, CourseStage } from '../models/CourseModel';
import { AiApiService } from '../services/AiApiService';
import { Validator, Logger } from '../utils/Utils';

@Entry
@Component
export struct HomePage {
  @State searchQuery: string = '';
  @State isLoading: boolean = false;
  @State courses: CourseModel[] = [];
  private courseStore: CourseStore = new CourseStore('user_default');
  @State showCourseList: boolean = false;

  aboutToAppear(): void {
    this.courses = this.courseStore.getActiveCourses();
    this.showCourseList = this.courses.length > 0;
  }

  build() {
    Column() {
      Row() {
        this.TitleBar()
      }
      .width('100%')
      .padding({ left: 20, right: 20, top: 50 })

      Column() {
        this.SearchBox()
      }
      .width('100%')
      .padding({ left: 20, right: 20, top: 60 })

      if (this.isLoading) {
        this.LoadingView()
      }

      if (this.showCourseList && !this.isLoading) {
        this.CourseListView()
      }

      if (!this.showCourseList && !this.isLoading) {
        this.EmptyView()
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F2F2F7')
  }

  @Builder TitleBar() {
    Text('三问高效学习机')
      .fontSize(22)
      .fontWeight(FontWeight.Bold)
      .fontColor('#1D1D1F')
    Blank()
    Text('⚙️')
      .fontSize(20)
      .onClick(() => {
        router.pushUrl({ url: 'pages/ProfilePage' });
      })
  }

  @Builder SearchBox() {
    Column() {
      Text('今天想攻克什么知识？')
        .fontSize(18)
        .fontColor('#6E6E73')
        .margin({ bottom: 20 })

      Row() {
        TextInput({ placeholder: '例如：如何快速掌握鸿蒙ArkTS开发？', text: this.searchQuery })
          .layoutWeight(1)
          .height(52)
          .fontSize(15)
          .backgroundColor('#F2F2F7')
          .borderRadius(26)
          .padding({ left: 20, right: 20 })
          .onChange((value: string) => {
            this.searchQuery = value;
          })
          .onSubmit(() => {
            this.handleSearch();
          })

        Button('开始学习')
          .fontSize(15)
          .fontColor('#FFFFFF')
          .backgroundColor('#1A73E8')
          .borderRadius(26)
          .height(52)
          .padding({ left: 20, right: 20 })
          .margin({ left: 10 })
          .enabled(!this.isLoading && Validator.isValidQuestion(this.searchQuery))
          .onClick(() => {
            this.handleSearch();
          })
      }
      .width('100%')
    }
  }

  @Builder LoadingView() {
    Column() {
      LoadingProgress()
        .width(40)
        .height(40)
        .color('#1A73E8')
      Text('正在生成课程和知识库...')
        .fontSize(14)
        .fontColor('#8E8E93')
        .margin({ top: 12 })
    }
    .width('100%')
    .margin({ top: 60 })
  }

  @Builder CourseListView() {
    Column() {
      Row() {
        Text('最近学习')
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1D1D1F')
        Blank()
        Text(this.getActiveCount())
          .fontSize(12)
          .fontColor('#8E8E93')
      }
      .width('100%')
      .margin({ top: 30, bottom: 12 })
      .padding({ left: 20, right: 20 })

      List() {
        ForEach(this.courses, (course: CourseModel) => {
          ListItem() {
            CourseCard({
              course: course,
              onCardClick: (courseId: string) => {
                this.courseStore.currentCourseId = courseId;
                router.pushUrl({ url: 'pages/CourseSpacePage', params: { courseId: courseId } });
              }
            })
          }
          .padding({ left: 16, right: 16 })
        })
      }
      .width('100%')
      .layoutWeight(1)
    }
    .width('100%')
    .layoutWeight(1)
  }

  @Builder EmptyView() {
    Column() {
      Text('💡')
        .fontSize(48)
        .margin({ bottom: 12 })
      Text('提出问题，即刻创建专属课程')
        .fontSize(15)
        .fontColor('#8E8E93')
    }
    .width('100%')
    .layoutWeight(1)
    .justifyContent(FlexAlign.Center)
  }

  getActiveCount(): string {
    const n = this.courses.filter((c: CourseModel) => c.stage !== CourseStage.COMPLETED).length;
    return n.toString() + '门进行中';
  }

  handleSearch(): void {
    if (!Validator.isValidQuestion(this.searchQuery)) {
      return;
    }
    this.isLoading = true;
    Logger.info('HomePage', 'Creating course for: ' + this.searchQuery);

    const course = this.courseStore.createCourse(this.searchQuery, 'user_default');
    this.courses = this.courseStore.getActiveCourses();
    this.showCourseList = true;
    const courseId = course.id;
    const query = this.searchQuery;
    this.searchQuery = '';

    AiApiService.createCourse(query, 'user_default').then((res) => {
      if (res.code === 200 && res.data) {
        AiApiService.crawlMaterials(courseId).catch(() => {});
      }
    }).catch(() => {});

    this.isLoading = false;
    router.pushUrl({ url: 'pages/CourseSpacePage', params: { courseId: courseId } });
  }
}
