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
    keyword: String,
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
    // let keyword = ref(props.keyword)
    let keyword = props.keyword

    let params = { keyword: keyword }
    let query = new URLSearchParams(params);

    let data = await fetch(`/api/v1/items?${query}`);
    let json = await data.json()
    let array = []
    for (let elem of json) {
      var x = elem[0];
      var y = elem[1];
      array.push({ x: x, y: y });
    };

    const chartData = {
      datasets: [
        {
          label: 'Scatter Dataset 1',
          fill: false,
          borderColor: '#f87979',
          backgroundColor: '#f87979',
          data: array
        }
      ]
    }

    const chartOptions = {
      responsive: true,
      maintainAspectRatio: false,
      scales: {
        x: {
          scaleLabel: {
            display: true,
            labelString: '時間'
          },
          type: 'time',
          time: {
            parser: 'YYYY-MM-DD',
            unit: 'day',
            stepSize: 1,
            displayFormats: {
              'hour': 'H時'
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