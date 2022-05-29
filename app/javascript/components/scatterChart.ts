import { defineComponent, h, PropType, onMounted } from 'vue'

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
interface MyObj {
  created_at: string
  id: number
  name: string
  price: string
  search_condition_id: number
  sold: string
  updated_at: string
  url: string
}

export default defineComponent({
  name: 'ScatterChart',
  components: {
    Scatter
  },
  props: {
    items: {
      type: Array as PropType<MyObj[]>
    },
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
      default: () => {}
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
          borderColor: 'rgb(54, 162, 235)',
          backgroundColor: 'rgba(54, 162, 235, 0.6)',
          data: props.sale_array
        },
        {
          label: 'sold',
          fill: false,
          borderColor: 'rgb(255, 99, 132)',
          backgroundColor: 'rgba(255, 99, 132, 0.6)',
          data: props.sold_array
        }
      ]
    }

    const items_array = props.items.concat()

    const getOrCreateTooltip = (chart) => {
      let tooltipEl = chart.canvas.parentNode.querySelector('div')

      if (!tooltipEl) {
        tooltipEl = document.createElement('div')
        tooltipEl.style.background = 'rgba(0, 0, 0, 0.7)'
        tooltipEl.style.borderRadius = '3px'
        tooltipEl.style.color = 'white'
        tooltipEl.style.opacity = 1
        tooltipEl.style.position = 'absolute'
        tooltipEl.style.transform = 'translate(-50%, 0)'
        tooltipEl.style.transition = 'all .1s ease'
        tooltipEl.style.pointerEvents = 'auto'

        const table = document.createElement('table')
        table.style.margin = '0px'
        table.style.zIndex = '-1'

        tooltipEl.appendChild(table)
        chart.canvas.parentNode.appendChild(tooltipEl)
      }

      return tooltipEl
    }

    const deleteChild = (tooltipEl) => {
      const tableRoot = tooltipEl.querySelector('table')
      // Remove old children
      while (tableRoot.firstChild) {
        tableRoot.firstChild.remove()
        tooltipEl.style.opacity = 0
      }
    }

    function isSmartPhone() {
      if (navigator.userAgent.match(/iPhone|Android.+Mobile/)) {
        return true;
      } else {
        return false;
      }
    }

    const externalTooltipHandler = (context) => {
      // Tooltip Element
      const { chart, tooltip } = context
      const tooltipEl = getOrCreateTooltip(chart)

      // Set Text
      if (tooltip.body) {
        const tableHead = document.createElement('thead')
        const tableBody = document.createElement('tbody')
        let data_collection = new Set()
        tooltip.dataPoints.forEach((dataPoint, i) => {
          let price = dataPoint.parsed.y
          let date = dataPoint.raw.x
          let sold = dataPoint.dataset.label

          let filtered_array = items_array.filter(
            (data) =>
              data.price === price && data.updated_at.slice(0, 10) === date && data.sold === sold
          )
          filtered_array.forEach((item) => {
            // 同じ価格のアイテムを順番に処理するため重複チェック
            if (data_collection.has(item)) {
              return
            }
            data_collection.add(item)

            const colors = tooltip.labelColors[i]
            const span = document.createElement('span')
            span.style.background = colors.backgroundColor
            span.style.borderColor = colors.borderColor
            span.style.borderWidth = '1px'
            span.style.marginRight = '10px'
            span.style.height = '10px'
            span.style.width = '10px'
            span.style.display = 'inline-block'

            const tr = document.createElement('tr')
            tr.style.backgroundColor = 'inherit'
            tr.style.borderWidth = '0'

            const td = document.createElement('td')
            td.style.borderWidth = '0'

            let label = ''
            label += new Intl.NumberFormat('ja-JP', {
              style: 'currency',
              currency: 'JPY'
            }).format(price)

            if (label) {
              label += ': '
            }

            let link = document.createElement('a')
            link.setAttribute('href', item.url)
            link.setAttribute('target', '_blank')
            link.appendChild(document.createTextNode(label + item.name))

            td.appendChild(span)
            td.appendChild(link)
            tr.appendChild(td)
            tableBody.appendChild(tr)
          })
        })

        const tableRoot = tooltipEl.querySelector('table')
        // Remove old children
        while (tableRoot.firstChild) {
          tableRoot.firstChild.remove()
        }
        // Add new children
        tableRoot.appendChild(tableHead)
        tableRoot.appendChild(tableBody)
      }

      const { offsetLeft: positionX, offsetTop: positionY } = chart.canvas

      // Display, position, and set styles for font
      tooltipEl.style.opacity = 1
      tooltipEl.style.left = positionX + tooltip.caretX + 'px'
      tooltipEl.style.top = positionY + tooltip.caretY / 2 + 'px'
      tooltipEl.style.font = tooltip.options.bodyFont.string
      tooltipEl.style.padding = tooltip.options.padding + 'px ' + tooltip.options.padding + 'px'

      if(isSmartPhone()){
        tooltipEl.addEventListener('touchend', function (e) {
          deleteChild(tooltipEl)
        })
      }else{
        tooltipEl.addEventListener('pointerleave', function (e) {
          deleteChild(tooltipEl)
        })
        document.addEventListener('click', function (e) {
          deleteChild(tooltipEl)
          
        })
      }
    }

    const label = (context) => {
      let label = "";
      if (context.parsed.y !== null) {
        label += new Intl.NumberFormat("ja-JP", {
          style: "currency",
          currency: "JPY",
        }).format(context.parsed.y);
      }
      if (label) {
        label += ": ";
      }
      let price = context.parsed.y;
      let date = context.dataset.data[context.dataIndex].x;
      let filtered_array = items_array.filter(
        (data) =>
          data.price === price &&
          data.updated_at.slice(0, 10) === date &&
          data.sold === context.dataset.label
      );
      label += filtered_array
        .map((x) => x.name)
        .reduce((acc, cur) => acc + ", " + cur);
      return label;
    };

    function selectTooltips() {
      if (navigator.userAgent.match(/iPhone|Android.+Mobile/)) {
        return {
          enabled: true,
          position: 'average',
          intersect: false,
          callbacks: {
            label: label,
          },
          itemSort: function (i0, i1) {
            var v0 = i0.parsed.y
            var v1 = i1.parsed.y
            return v0 > v1 ? -1 : v0 < v1 ? 1 : 0
          }
        }
      } else {
        return {
          enabled: false,
          position: 'average',
          intersect: false,
          external: externalTooltipHandler,
          itemSort: function (i0, i1) {
            var v0 = i0.parsed.y
            var v1 = i1.parsed.y
            return v0 > v1 ? -1 : v0 < v1 ? 1 : 0
          }
        }
      }
    }
    
    const chartOptions = {
      responsive: true,
      maintainAspectRatio: false,
      plugins: {
        title: {
          display: true,
          // text: '直近一週間で売れている価格帯'
        },
        tooltip: selectTooltips()
      },
      scales: {
        x: {
          label: {
            display: true,
          },
          type: 'time',
          time: {
            parser: 'YYYY-MM-DD',
            unit: 'day',
            stepSize: 1,
            displayFormats: {
              day: 'YYYY-MM-DD'
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
