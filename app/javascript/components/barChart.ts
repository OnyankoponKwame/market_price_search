import { defineComponent, h, PropType } from 'vue'

import { Bar } from 'vue-chartjs'

import {
  Chart as ChartJS,
  Title,
  Tooltip,
  Legend,
  BarElement,
  CategoryScale,
  LinearScale,
  Plugin
} from 'chart.js'

ChartJS.register(Title, Tooltip, Legend, BarElement, CategoryScale, LinearScale)

export default defineComponent({
  name: 'BarChart',
  components: {
    Bar
  },
  props: {
    data_array: {
      type: Array
    },
    label_array: {
      type: Array
    },
    chartId: {
      type: String,
      default: 'bar-chart'
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
      type: Array as PropType<Plugin<'bar'>[]>,
      default: () => []
    }
  },
  setup(props) {

    if(props.data_array == null){
      return
    }

    const chartData = {
      labels: props.label_array,
      datasets: [
        {
          label: 'sold',
          borderColor: 'rgb(255, 99, 132)',
          backgroundColor: 'rgba(255, 99, 132, 0.6)',
          data: props.data_array
        }
      ]
    }

    const chartOptions = {
      responsive: true,
      maintainAspectRatio: false,
      barPercentage: 1.0,
      borderWidth: 1,
      categoryPercentage: 1.0,
      plugins: {
        title: {
          display: true,
          text: '直近一週間で売れている価格帯'
        }
      }
    }

    return () =>
      h(Bar, {
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
