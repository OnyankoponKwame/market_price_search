import { defineComponent, h, PropType } from 'vue'

import { Scatter } from 'vue-chartjs'
import 'chartjs-adapter-moment'
import {
  Chart as ChartJS,
  Title,
  Tooltip,
  Legend,
  LineElement,
  TimeScale,
  TimeSeriesScale,
  CategoryScale,
  LinearScale,
  PointElement,
  Plugin
} from 'chart.js'

ChartJS.register(
  Title,
  Tooltip,
  Legend,
  LineElement,
  TimeScale,
  TimeSeriesScale,
  CategoryScale,
  LinearScale,
  PointElement
)

export default defineComponent({
  name: 'ScatterChart',
  components: {
    Scatter
  },
  props: {
    sale_array: {
      type: Array
    },
    sold_array: {
      type: Array
    },
    keyword: {
      type: String
    },
    chartId: {
      type: String,
      default: 'scatter-chart'
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
      default: () => { }
    },
    plugins: {
      type: Array as PropType<Plugin<'scatter'>[]>,
      default: () => []
    }
  },

  async setup(props) {

    const chartData = {
      datasets: [
        {
          label: 'sale',
          fill: false,
          borderColor: '#f87979',
          backgroundColor: '#f87979',
          data: props.sale_array
        },
        {
          label: 'sold',
          fill: false,
          borderColor: '#00b2ee',
          backgroundColor: '#00b2ee',
          data: props.sold_array
        }
      ]
    }

    const chartOptions = {
      responsive: true,
      maintainAspectRatio: false,
      scales: {
        x: {
          label: {
            display: true,
            labelString: '時間'
          },
          type: 'time',
          time: {
            parser: 'YYYY-MM-DD',
            unit: 'day',
            stepSize: 1,
            displayFormats: {
              'day': 'YYYY-MM-DD'
            }
          }
        }
      }
    }

    return () =>
      h(Scatter, {
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