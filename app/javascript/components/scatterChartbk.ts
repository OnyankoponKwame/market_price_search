import { defineComponent, h, PropType , onMounted} from "vue";

import { Scatter } from "vue-chartjs";
import "chartjs-adapter-moment";
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
  Plugin,
} from "chart.js";

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
);
interface MyObj {
  created_at: string;
  id: number;
  name: string;
  price: string;
  search_condition_id: number;
  sold: string;
  updated_at: string;
  url: string;
}

export default defineComponent({
  name: "ScatterChart",
  components: {
    Scatter,
  },
  props: {
    items: {
      type: Array as PropType<MyObj[]>,
    },
    sale_array: {
      type: Array,
    },
    sold_array: {
      type: Array,
    },
    keyword: {
      type: String,
    },
    chartId: {
      type: String,
      default: "scatter-chart",
    },
    width: {
      type: Number,
      default: 400,
    },
    height: {
      type: Number,
      default: 400,
    },
    cssClasses: {
      default: "",
      type: String,
    },
    styles: {
      type: Object as PropType<Partial<CSSStyleDeclaration>>,
      default: () => {},
    },
    plugins: {
      type: Array as PropType<Plugin<"scatter">[]>,
      default: () => [],
    },
  },

  async setup(props) {
    const chartData = {
      datasets: [
        {
          label: "sale",
          fill: false,
          borderColor: "#f87979",
          backgroundColor: "#f87979",
          data: props.sale_array,
        },
        {
          label: "sold",
          fill: false,
          borderColor: "#00b2ee",
          backgroundColor: "#00b2ee",
          data: props.sold_array,
        },
      ],
    };

    const items_array = props.items.concat();

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
      return '<a href="foo">filter</a>' + label;
    };

    // document.getElementById('cvr_graph-tooltip').addEventListener('mouseenter', function(e) {
    //   console.log(e.pageX, e.pageY, e.clientX, e.clientY, e.offsetX, e.offsetY)
    // })

    const chartOptions = {
      responsive: true,
      maintainAspectRatio: false,
    //   onClick: function(evt, array) {
    //     if (array.length != 0) {
    //         var position = array[0]._index;
    //         var activeElement = this.tooltip._data.datasets[0].data[position]
    //         console.log(activeElement);
    //     } else {
    //         console.log("You selected the background!");            
    //     }  
    // },
      plugins: {
        title: {
          display: true,
          text: "直近一週間で売れている価格帯",
        },
        tooltip: {
          enabled: false,
          external: function(context) {
              // Tooltip Element
              let tooltipEl = document.getElementById('chartjs-tooltip');

              // Create element on first render
              if (!tooltipEl) {
                  tooltipEl = document.createElement('div');
                  tooltipEl.id = 'chartjs-tooltip';
                  tooltipEl.innerHTML = '<table></table>';
                  document.body.appendChild(tooltipEl);
              }

              // Hide if no tooltip
              const tooltipModel = context.tooltip;
              if (tooltipModel.opacity === 0) {
                  tooltipEl.style.opacity = '1';
                  return;
              }

              // Set caret Position
              tooltipEl.classList.remove('above', 'below', 'no-transform');
              if (tooltipModel.yAlign) {
                  tooltipEl.classList.add(tooltipModel.yAlign);
              } else {
                  tooltipEl.classList.add('no-transform');
              }

              function getBody(bodyItem) {
                  return bodyItem.lines;
              }

              // Set Text
              if (tooltipModel.body) {
                  const titleLines = tooltipModel.title || [];
                  const bodyLines = tooltipModel.body.map(getBody);

                  let innerHtml = '<thead>';

                  titleLines.forEach(function(title) {
                      innerHtml += '<tr><th>' + title + '</th></tr>';
                  });
                  innerHtml += '</thead><tbody>';

                  bodyLines.forEach(function(body, i) {
                      const colors = tooltipModel.labelColors[i];
                      let style = 'background:' + colors.backgroundColor;
                      style += '; border-color:' + colors.borderColor;
                      style += '; border-width: 2px';
                      const span = '<span style="' + style + '"></span>';
                      innerHtml += '<tr><td>' + span + body + '</td></tr>';
                  });
                  innerHtml += '<a href="https://www.yahoo.co.jp/" target="_blank">aa</a>'
                  innerHtml += '</tbody>';

                  let tableRoot = tooltipEl.querySelector('table');
                  tableRoot.innerHTML = innerHtml;
              }

              const position = context.chart.canvas.getBoundingClientRect();
              // const bodyFont = Chart.helpers.toFont(tooltipModel.options.bodyFont);

              // Display, position, and set styles for font
              tooltipEl.style.opacity = 1;
              tooltipEl.style.position = 'absolute';
              tooltipEl.style.left = position.left + window.pageXOffset + tooltipModel.caretX + 'px';
              tooltipEl.style.top = position.top + window.pageYOffset + tooltipModel.caretY + 'px';
              // tooltipEl.style.font = bodyFont.string;
              tooltipEl.style.padding = tooltipModel.padding + 'px ' + tooltipModel.padding + 'px';
              tooltipEl.style.pointerEvents = 'none';
              tooltipEl.addEventListener('mouseenter', function(e) {
                console.log(e.pageX, e.pageY, e.clientX, e.clientY, e.offsetX, e.offsetY)
                alert()
                tooltipEl.style.opacity = '1'
              })
          },
          // callbacks: {
          //   label: label,
          // },
          itemSort: function (i0, i1) {
            var v0 = i0.parsed.y;
            var v1 = i1.parsed.y;
            return v0 > v1 ? -1 : v0 < v1 ? 1 : 0;
          },
        },
      },
      scales: {
        x: {
          label: {
            display: true,
            labelString: "時間",
          },
          type: "time",
          time: {
            parser: "YYYY-MM-DD",
            unit: "day",
            stepSize: 1,
            displayFormats: {
              day: "YYYY-MM-DD",
            },
          },
        },
      },
    };

    return () =>
      h(Scatter, {
        chartData,
        chartOptions,
        chartId: props.chartId,
        width: props.width,
        height: props.height,
        cssClasses: props.cssClasses,
        styles: props.styles,
        plugins: props.plugins,
      });
  },
});
