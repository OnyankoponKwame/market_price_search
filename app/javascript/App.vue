<template>
  <div class="container">
    <!-- スマホ用 -->
    <div class="d-md-none">
      <div class="row pt-3 d-flex">
        <div class="col-7 ps-1 g-0">
          <a href="/">
            <img :src="'title-x38.jpeg'" class="img-fluid" alt="フリマチャート" />
          </a>
        </div>
        <div class="col-auto ms-auto">
          <button
            type="button"
            class="btn btn-outline-danger"
            data-bs-toggle="tooltip"
            data-bs-placement="bottom"
            data-bs-custom-class="custom-tooltip"
            title="定期実行登録すると毎日登録した検索条件で検索されデータベースに蓄積されます。再度押すと登録が解除されます。"
            v-on:click="postChart()"
          >
            定期実行登録
          </button>
        </div>
        <div class="col-12">
          <div class="input-group">
            <input v-model="keyword" @input="historyDisplay" type="text" class="form-control" aria-describedby="button-addon2" />
            <button class="btn btn-primary" type="button" id="button-addon2" v-on:click="updateChart()">検索</button>
          </div>
        </div>
      </div>
    </div>
    <!-- PC用 -->
    <div class="d-none d-md-block">
      <div class="row pt-3">
        <div class="col-md-3 g-0">
          <a href="/">
            <img :src="'title-x38.jpeg'" class="img-fluid" alt="フリマチャート" />
          </a>
        </div>
        <div class="col-md-5 offset-md-2">
          <div class="input-group">
            <input v-model="keyword" @input="historyDisplay" type="text" class="form-control" aria-describedby="button-addon2" />
            <button class="btn btn-primary" type="button" id="button-addon2" v-on:click="updateChart()">検索</button>
          </div>
        </div>
        <div class="col-md">
          <button
            type="button"
            class="btn btn-outline-danger"
            data-bs-toggle="tooltip"
            data-bs-placement="bottom"
            data-bs-custom-class="custom-tooltip"
            title="定期実行登録すると毎日登録した検索条件で検索されデータベースに蓄積されます。再度押すと登録が解除されます。"
            v-on:click="postChart()"
          >
            定期実行登録
          </button>
        </div>
      </div>
    </div>

    <!-- ここから絞り込み -->
    <div class="row mb-3 pt-3">
      <!-- スマホ用 -->
      <div class="d-md-none">
        <details>
          <summary>詳細検索</summary>
          <div class="col-12 border rounded shiborikomi">
            <div class="h5 pb-2 mb-3 text-dark border-bottom d-flex">
              絞り込み
              <button type="button" class="btn btn-outline-primary ms-auto py-0" v-on:click="clearInput()">クリア</button>
            </div>
            <div class="col-12 mb-3">
              <label>価格</label>
              <div class="input-group">
                <input v-model="price_min" type="number" step="10" min="300" placeholder="Min" aria-label="Min" class="form-control" />
                <input v-model="price_max" type="number" step="10" min="300" placeholder="Max" aria-label="Max" class="form-control" />
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
          </div>
        </details>
      </div>
      <!-- PC用 -->
      <div class="col-md-3 h-50 border rounded d-none d-md-block shiborikomi" style="width: 250px">
        <div class="h5 pb-2 mb-3 text-dark border-bottom d-flex">
          絞り込み
          <button type="button" class="btn btn-outline-primary ms-auto py-0" v-on:click="clearInput()">クリア</button>
        </div>
        <div class="col-12 mb-3">
          <label>価格</label>
          <div class="input-group">
            <input v-model="price_min" type="number" step="10" min="300" placeholder="Min" aria-label="Min" class="form-control" />
            <input v-model="price_max" type="number" step="10" min="300" placeholder="Max" aria-label="Max" class="form-control" />
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
      </div>
      <!-- チャート部分 -->
      <div class="col-md">
        <div v-if="response_message" :class="message_type">{{ response_message }}</div>
        <div v-if="isLoading" class="text-center text-secondary">
          <div class="spinner-border spinner-border-sm" role="status">
            <span class="visually-hidden">Loading...</span>
          </div>
          読み込み中...
        </div>
        <div v-else-if="history_display_flag">
          <div v-for="search_condition in search_condition_array" :key="search_condition.keyword" class="border-bottom col-md-9 offset-md-2">
            <div class="d-flex">
              <div class="me-auto align-self-center">
                <span class="fw-bold">
                  {{ search_condition.keyword }}
                </span>
                &nbsp;
                <span v-if="search_condition.price_min">Min:¥{{ search_condition.price_min }}&nbsp;</span>
                <span v-if="search_condition.price_max">Max:¥{{ search_condition.price_max }}&nbsp;</span>
                <span v-if="search_condition.negative_keyword">除外:{{ search_condition.negative_keyword }}&nbsp;</span>
                <span v-if="search_condition.include_title_flag">タイトルに含む</span>
              </div>
              <div>
                <button type="button" class="btn btn-default" v-on:click="updateChart(search_condition)">
                  <i class="fa-solid fa-angle-right"></i>
                </button>
                <button type="button" class="btn btn-default text-danger" v-on:click="deleteHistory(search_condition)">
                  <i class="fa-solid fa-xmark"></i>
                </button>
              </div>
            </div>
          </div>
        </div>
        <div v-else>
          <Suspense>
            <LineChart v-if="chart_display_flag" :line_graph_data="line_graph_data" />
          </Suspense>
          <Suspense>
            <ScatterChart v-if="chart_display_flag" :sale_array="sale_array" :sold_array="sold_array" :items="items" />
          </Suspense>
          <Suspense>
            <BarChart v-if="chart_display_flag" :data_array="data_array" :label_array="label_array" />
          </Suspense>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import ScatterChart from './components/scatterChart'
import BarChart from './components/barChart'
import LineChart from './components/lineChart'
import { onMounted, ref, reactive, toRaw } from 'vue'

export default {
  components: {
    ScatterChart,
    BarChart,
    LineChart
  },

  setup() {
    let chart_display_flag = ref(false)
    let keyword = ref('')
    let price_min = ref('')
    let price_max = ref('')
    let negative_keyword = ref('')
    let include_title_flag = ref(false)
    let sale_array = ref([])
    let sold_array = ref([])
    let data_array = ref([])
    let label_array = ref([])
    let line_graph_data = ref({})
    let items = ref([])
    let isLoading = ref(false)
    let response_message = ref('')
    let search_condition_array = reactive([])
    let history_display_flag = ref(false)
    let message_type = ref('')

    function Initialization() {
      let localSt = localStorage.getItem('search_conditions')
      if (localSt != null) {
        search_condition_array = reactive(JSON.parse(localSt))
        history_display_flag.value = true
      }
    }
    Initialization()

    function historyDisplay() {
      if (keyword.value.trim()) {
        history_display_flag.value = false
      } else {
        history_display_flag.value = true
        response_message.value = ''
        isLoading.value = false
        chart_display_flag.value = false
      }
    }
    const updateChart = async (search_condition = '') => {
      if (keyword.value.trim() == '' && !search_condition) {
        return
      }
      isLoading.value = true
      // 引数が設定されている場合（検索履歴）そちらのデータで検索
      if (search_condition) {
        keyword.value = search_condition.keyword
        price_min.value = search_condition.price_min
        price_max.value = search_condition.price_max
        negative_keyword.value = search_condition.negative_keyword
        include_title_flag.value = search_condition.include_title_flag
      }
      let params = {
        keyword: keyword.value,
        price_min: price_min.value,
        price_max: price_max.value,
        negative_keyword: negative_keyword.value,
        include_title_flag: include_title_flag.value
      }
      price_min.value > price_max.value

      // Localstorage
      // 検索履歴に同じ条件あった場合は追加しない
      if (!toRaw(search_condition_array).some((e) => JSON.stringify(e) === JSON.stringify(params))) {
        search_condition_array.push(params)
        localStorage.setItem('search_conditions', JSON.stringify(search_condition_array))
      }
      let query = new URLSearchParams(params)
      sale_array.value = []
      sold_array.value = []
      data_array.value = []
      label_array.value = []
      line_graph_data.value = {}
      items.value = []

      const res = await fetch(`/api/v1/items?${query}`)
      if (checkresponse(res)) {
        // OKじゃなければreturn
        isLoading.value = false
        return
      }
      const json = await res.json()
      if (json['message']) {
        response_message.value = json['message']
        message_type.value = 'text-center text-info'
        return
      }

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
      line_graph_data.value = json['line_graph_data']
      items.value = JSON.parse(json['items'])
      isLoading.value = false
      history_display_flag.value = false
      chart_display_flag.value = true
    }

    const postChart = async () => {
      if (!keyword.value.trim()) return
      let params = {
        keyword: keyword.value,
        price_min: price_min.value,
        price_max: price_max.value
      }
      const res = await fetch('/search_conditions', {
        method: 'POST',
        credentials: 'same-origin',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': getCsrfToken()
        },
        body: JSON.stringify(params)
      })
      const json = await res.json()
      if (checkresponse(res)) {
        return
      }
      message_type.value = 'text-center text-success'
      if (json['cron_flag']) {
        response_message.value = '定期実行を登録しました。'
      } else {
        response_message.value = '定期実行を解除しました。'
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
        response_message.value = res.status + ':' + res.statusText
        message_type.value = 'text-center text-danger'
        console.log(response_message.value)
      } else {
        response_message.value = ''
      }
      return !res.ok
    }

    function clearInput() {
      price_min.value = ''
      price_max.value = ''
      negative_keyword.value = ''
      include_title_flag.value = ''
    }

    function deleteHistory(search_condition) {
      let index = search_condition_array.indexOf(search_condition)
      search_condition_array.splice(index, 1)
      localStorage.setItem('search_conditions', JSON.stringify(search_condition_array))
    }

    onMounted(() => {
      const tooltipTriggerList = document.querySelectorAll('[data-bs-toggle="tooltip"]')
      const tooltipList = [...tooltipTriggerList].map((tooltipTriggerEl) => new bootstrap.Tooltip(tooltipTriggerEl))
    })

    return {
      updateChart,
      postChart,
      clearInput,
      deleteHistory,
      historyDisplay,
      keyword,
      price_min,
      price_max,
      negative_keyword,
      include_title_flag,
      chart_display_flag,
      sale_array,
      sold_array,
      data_array,
      label_array,
      line_graph_data,
      items,
      isLoading,
      response_message,
      search_condition_array,
      history_display_flag,
      message_type
    }
  }
}
</script>

<style>
.shiborikomi {
  background-color: rgb(250, 250, 250);
  padding: 8px;
  border-radius: 15px;
}
summary {
  transition: 0.2s; /* 変化を滑らかに */
  text-align: center;
  background-color: #efefef;
  border-radius: 5px;
}
.custom-tooltip {
  --bs-tooltip-bg: var(--bs-secondary);
}
</style>