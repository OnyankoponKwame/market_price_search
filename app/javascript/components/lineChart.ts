import { defineComponent, h, PropType } from 'vue'

import { Line } from 'vue-chartjs'
import {
  Chart as ChartJS,
  Title,
  Tooltip,
  Legend,
  LineElement,
  LinearScale,
  PointElement,
  CategoryScale,
  Plugin
} from 'chart.js'

ChartJS.register(
  Title,
  Tooltip,
  Legend,
  LineElement,
  LinearScale,
  PointElement,
  CategoryScale
)

export default defineComponent({
  name: 'LineChart',
  components: {
    Line
  },
  props: {
    line_graph_data: {
      type: Object
    },
    chartId: {
      type: String,
      default: 'line-chart'
    },
    width: {
      type: Number,
      default: 400
    },
    height: {
      type: Number,
      default: 400
    },
    cssClasses: {
      default: '',
      type: String
    },
    styles: {
      type: Object as PropType<Partial<CSSStyleDeclaration>>,
      default: () => {}
    },
    plugins: {
      type: Array as PropType<Plugin<'line'>[]>,
      default: () => []
    }
  },
  setup(props) {
    const chartData = {
      labels: props.line_graph_data.labels,
      datasets: [
        {
          label: '平均値',
          borderColor: 'rgb(255, 241, 0, 0.6)',
          backgroundColor: 'rgba(255, 241, 0)',
          data: props.line_graph_data.average,
        },
        {
          label: '中央値',
          borderColor: 'rgb(255, 75, 0, 0.6)',
          backgroundColor: 'rgba(255, 75, 0)',
          data: props.line_graph_data.median,
        },
        {
          label: '最頻値',
          borderColor: 'rgb(3, 175, 122, 0.6)',
          backgroundColor: 'rgba(3, 175, 122',
          data: props.line_graph_data.mode,
        }
      ]
    }

    const chartOptions = {
      responsive: true,
      maintainAspectRatio: false,
      plugins: {
        title: {
          display: true,
          text: '価格推移'
        }
      }
    }

    return () =>
      h(Line, {
        chartData,
        chartOptions,
        chartId: props.chartId,
        width: props.width,
        height: props.height,
        cssClasses: props.cssClasses,
        styles: props.styles,
        plugins: props.plugins
      })
  }
})
