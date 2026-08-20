import { MindNode, MindEdge } from '../models/CourseModel';

@Component
export struct KnowledgeGraphView {
  @Prop nodes: MindNode[] = [];
  @Prop edges: MindEdge[] = [];
  @State expandedNodes: string[] = [];
  onNodeClick?: (node: MindNode) => void;

  build() {
    Column() {
      Text('核心心智模型')
        .fontSize(16).fontWeight(FontWeight.Bold).fontColor('#1D1D1F').margin({ bottom: 12 }).width('100%')

      if (this.nodes.length === 0) {
        Column() {
          LoadingProgress().width(40).height(40)
          Text('正在构建心智模型...').fontSize(14).fontColor('#8E8E93').margin({ top: 8 })
        }
        .width('100%').height(120).justifyContent(FlexAlign.Center)
      } else {
        List() {
          ForEach(this.nodes, (node: MindNode) => {
            ListItem() {
              Row() {
                Text('●').fontSize(8).fontColor(this.nodeStatusColor(node.status)).margin({ right: 6 })
                Text(node.label).fontSize(14)
                  .fontWeight(FontWeight.Bold).fontColor('#1D1D1F').layoutWeight(1)
                if (node.sources.length > 0) {
                  Text(node.sources.length.toString()).fontSize(10).fontColor('#1A73E8')
                    .padding({ left: 6, right: 6, top: 1, bottom: 1 })
                    .backgroundColor('#E3F2FD').borderRadius(8)
                }
                if (node.status === 'understood') {
                  Text('✓').fontSize(14).fontColor('#34C759').margin({ left: 6 })
                }
              }
              .width('100%').padding({ top: 8, bottom: 8 })
              .onClick(() => { if (this.onNodeClick) this.onNodeClick(node) })
            }
          })
        }
        .width('100%')
      }
    }
    .width('100%').padding(12).backgroundColor('#F8FAFD').borderRadius(12)
  }

  nodeStatusColor(status: string): string {
    if (status === 'understood') return '#34C759'
    if (status === 'confused') return '#FF9500'
    return '#1A73E8'
  }
}
