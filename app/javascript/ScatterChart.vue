<template>
  <div class="container">
    <Scatter v-if="loaded" :chart-data="chartData" :chart-options="chartOptions" />
  </div>
</template>

<script>
import { Scatter } from 'vue-chartjs'
import { Chart as ChartJS, Title, Tooltip, Legend, BarElement, CategoryScale, LinearScale } from 'chart.js'
import axios from 'axios'

ChartJS.register(Title, Tooltip, Legend, BarElement, CategoryScale, LinearScale)

export default {
  name: 'ScatterChart',
  components: { Scatter },
  data: () => ({
    loaded: false,
    chartData: null
  }),
  async mounted () {
    this.loaded = false

    try {
      // const { userlist } = await fetch('https://api.coindesk.com/v1/bpi/currentprice.json')
      const data = await fetch('/api/v1/items.json')
      const json = await data.json()
      var array = [];
      for (const elem of json) {
        var x = elem[0];
        var y = elem[1];
        array.push( { x:x, y:y });
      };

      const userlist = {
        'datasets': [
          {
            'data': [
              {
                'x': -2,
                'y': 4
              },
              {
                'x': -1,
                'y': 1
              }
            ]
          }
        ]
      }

      this.chartdata = userlist
      
      this.loaded = true
    } catch (e) {
      console.error(e)
    }
  }
}
</script>