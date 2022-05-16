import { defineComponent, h, PropType } from "vue";

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
      return label;
    };

    const chartOptions = {
      responsive: true,
      maintainAspectRatio: false,
      plugins: {
        title: {
          display: true,
          text: "直近一週間で売れている価格帯",
        },
        tooltip: {
          callbacks: {
            label: label,
          },
          itemSort: function (i0, i1) {
            var v0 = i0.parsed.y; // or yLabel
            var v1 = i1.parsed.y; // or yLabel
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
