<template>
  <div>
    <canvas ref="canvasRef" />
  </div>
</template>

<script lang="ts">
import { defineComponent, onMounted, ref, watch, computed, reactive } from 'vue'
import { Chart } from 'chart.js'
import { options } from '@/config/config'
import { TChartData } from '@/data/data'

export default defineComponent({
  name: 'chart',
  props: {
    chartData: {
      type: TChartData,
      required: true
    },
    chartType: {
      type: Number,
      required: true
    }
  },
  setup (props) {
    // チャートに表示させるデータをまとめたオブジェクト
    const data = {
      dataSets: props.chartData,
      dataOptions: options
    }

    // 初期表示
    onMounted(() => {
      createCharts()
    })

    // computedせずに再代入するとreactiveではなくなってしまう。
    const chartType = computed(() => props.chartType)
    // chartTypeが変更されたかどうかを監視
    // 変更されたらChartを変更
    watch(chartType, () => {
      createCharts()
    })

    // canvasに対してref設定
    const canvasRef = ref<HTMLCanvasElement | null>(null)

    function getSelectedData () {
      const dataArray = Object.entries(data.dataSets)
      const newData = Object.entries(dataArray[0][1])
      const selectedArray = []
      newData.map(item => {
        if (chartType.value === Number(item[0])) {
          selectedArray.push(item[1])
        }
      })
      return selectedArray
    }

    const obj = {}

    function createCharts () {
      const data = getSelectedData()[0]
      if (canvasRef.value === null) return
      const canvas = canvasRef.value.getContext('2d')
      if (canvas === null) return
      // すでにチャートが作られていたら更新処理をする
      if (obj.chart instanceof Chart) {
        obj.chart.data.datasets[0] = data.datasets
        obj.chart.update()
      } else {
        // 初期表示の時だけチャートを生成
        const c = new Chart(canvas, {
          type: 'bar',
          data: {
            labels: data.labels,
            datasets: [{
              label: data.datasets.label,
              data: data.datasets.data
            }]
          }
        })
        obj.chart = c
      }
    }

    return {
      data,
      canvasRef
    }
  }
})
</script>
<style></style>