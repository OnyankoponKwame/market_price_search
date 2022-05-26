<template>
  <div class="container">
    <div class="row pt-3">
      <div class="col-md-3 g-0">
        <img src="/assets/title-x38.jpeg" class="img-fluid" alt="フリマチャート" />
      </div>
      <div class="col-md-5 offset-md-2">
        <!-- <div class="float-end"> -->
        <div class="input-group">
          <input v-model="keyword" type="text" class="form-control" aria-describedby="button-addon2" />
          <button class="btn btn-primary" type="button" id="button-addon2" v-on:click="updateChart()">検索</button>
        </div>
      </div>
      <!-- </div> -->
      <div class="col-md d-none d-md-block">
        <button type="button" class="btn btn-outline-danger ms-auto" v-on:click="postChart()">定期実行登録</button>
      </div>
    </div>

    <div class="row mb-3 pt-3">
      <!-- ここから絞り込み -->
      <div class="col-md-3 h-50 border rounded d-none d-md-block shiborikomi">
        <div class="h5 pb-2 mb-3 text-dark border-bottom d-flex">
          絞り込み
          <button type="button" class="btn btn-outline-primary ms-auto py-0" v-on:click="clearInput()">クリア</button>
        </div>
        <div class="col-12 mb-3">
          <label>価格</label>
          <div class="input-group">
            <input v-model="price_min" placeholder="Min" aria-label="Min" class="form-control" />
            <input v-model="price_max" placeholder="Max" aria-label="Max" class="form-control" />
          </div>
        </div>

        <div class="col-12 mb-2">
          <label>除外ワード</label>
          <div class="input-group">
            <input v-model="negative_keyword" placeholder="〜を含まない" aria-label="Min" class="form-control" />
          </div>
        </div>

        <div class="col-12">
          <div class="form-check">
            <input v-model="include_title_flag" class="form-check-input" type="checkbox" value="" id="flexCheckDefault" />
            <label class="form-check-label" for="flexCheckDefault" style="font-size: 0.9rem"> タイトルに検索ワードを含む </label>
          </div>
        </div>
        <!-- </div> -->
      </div>
      <div class="col-md">
        <div v-if="isError" class="text-center text-danger">エラー{{ response_message }}</div>
        <div v-else-if="isLoading" class="text-center text-secondary">読み込み中...</div>
        <div v-else-if="result_message" class="text-center text-success">{{ result_message }}</div>
        <div v-else>
          <Suspense>
            <ScatterChart :key="resetKey" v-if="resetFlag" :keyword="keyword" :sale_array="sale_array" :sold_array="sold_array" :items="items" />
          </Suspense>
          <Suspense>
            <BarChart :key="resetKey" v-if="resetFlag" :keyword="keyword" :data_array="data_array" :label_array="label_array" />
          </Suspense>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import ScatterChart from './components/scatterChart'
import BarChart from './components/barChart'
import { ref } from 'vue'

export default {
  components: {
    ScatterChart,
    BarChart
  },

  setup() {
    let resetFlag = ref(false)
    let resetKey = ref(0)
    let keyword = ref('')
    let price_min = ref('')
    let price_max = ref('')
    let negative_keyword = ref('')
    let include_title_flag = ref(false)
    let sale_array = ref([])
    let sold_array = ref([])
    let data_array = ref([])
    let label_array = ref([])
    let items = ref([])
    let isLoading = ref(false)
    let isError = ref(false)
    let response_message = ref('')
    let result_message = ref('')

    function shokihyouji() {
      let localSt = localStorage.getItem('search_condition')
      if (localSt != null) {
        let search_condition_array = JSON.parse(localSt)
        

      }

    }

    const updateChart = async () => {
      result_message.value = ''
      if (keyword.value.trim()) {
        isLoading.value = true
        let params = {
          keyword: keyword.value,
          price_min: price_min.value,
          price_max: price_max.value,
          negative_keyword: negative_keyword.value,
          include_title_flag: include_title_flag.value
        }
        // Localstorage
        let params_json = []
        params_json.push(params)

        let localSt = localStorage.getItem('search_condition')
        if (localSt == null) {
          localStorage.setItem('search_condition', JSON.stringify(params_json))
        } else {
          let search_condition_array = JSON.parse(localSt)
          search_condition_array.push(params)
          localStorage.setItem('search_condition', JSON.stringify(search_condition_array))
        }

        let query = new URLSearchParams(params)
        sale_array.value = []
        sold_array.value = []
        data_array.value = []
        label_array.value = []
        items.value = []
        const res = await fetch(`/api/v1/items?${query}`)
        if (checkresponse(res)) {
          return
        }
        const json = await res.json()
        for (let elem of json['sale_array']) {
          let x = elem[0]
          let y = elem[1]
          sale_array.value.push({ x: x, y: y })
        }
        for (let elem of json['sold_array']) {
          let x = elem[0]
          let y = elem[1]
          sold_array.value.push({ x: x, y: y })
        }
        data_array.value = json['data_array']
        label_array.value = json['label_array']
        items.value = JSON.parse(json['items'])
        isLoading.value = false

        resetFlag.value = true
        resetKey.value++
      } else {
        resetFlag.value = false
      }
    }

    const postChart = async () => {
      if (!keyword.value.trim()) return
      let params = { keyword: keyword.value }
      const res = await fetch('/search_conditions', {
        method: 'POST',
        credentials: 'same-origin',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': getCsrfToken()
        },
        body: JSON.stringify(params)
      })
      if (checkresponse(res)) {
        return
      }
      const json = await res.json()
      if (json['cron_flag']) {
        result_message.value = '定期実行を登録しました。'
      } else {
        result_message.value = '定期実行を解除しました。'
      }
    }

    const getCsrfToken = () => {
      const metas = document.getElementsByTagName('meta')
      for (let meta of metas) {
        if (meta.getAttribute('name') === 'csrf-token') {
          console.log('csrf-token:', meta.getAttribute('content'))
          return meta.getAttribute('content')
        }
      }
      return ''
    }

    function checkresponse(res) {
      if (!res.ok) {
        response_message.value = ' ' + res.status + ':' + res.statusText
        console.log(response_message.value)
        isError.value = true
      } else {
        isError.value = false
      }
      return isError.value
    }

    function clearInput() {
      price_min.value = ''
      price_max.value = ''
      negative_keyword.value = ''
      include_title_flag.value = ''
    }

    return {
      updateChart,
      postChart,
      clearInput,
      keyword,
      price_min,
      price_max,
      negative_keyword,
      include_title_flag,
      resetFlag,
      resetKey,
      sale_array,
      sold_array,
      data_array,
      label_array,
      items,
      isLoading,
      isError,
      response_message,
      result_message
    }
  }
}
</script>

<style>
.shiborikomi {
  background-color: rgb(250, 250, 250);
  padding: 8px;
  border-radius: 15px;
  width: 250px;
}
</style>