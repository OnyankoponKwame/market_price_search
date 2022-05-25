<template>
  <div class="container">
    <div class="row">
      <div class="col-md-auto">
        <img src="/assets/title-x38.jpeg" class="img-fluid" alt="フリマチャート" />
      </div>
      <div class="col-md-6">
        <div class="float-end">
        <div class="input-group">
          <input v-model="keyword" type="text" class="form-control" placeholder="Recipient's username" aria-label="Recipient's username" aria-describedby="button-addon2" />
          <button class="btn btn-primary" type="button" id="button-addon2" v-on:click="updateChart()">検索</button>
        </div>
        <button type="button" class="btn btn-outline-danger" v-on:click="postChart()">定期実行登録</button>
        </div>
      </div>
    </div>
    <!-- ここから絞り込み -->
    <div class="row mb-3 pt-3">
      <div class="col-md-3 border rounded d-none d-md-block shiborikomi">
        <div class="h5 pb-2 mb-3 text-dark border-bottom">絞り込み</div>
        <div class="row">
          <label>価格</label>
          <div class="input-group">
            <input v-model="price_min" placeholder="Min" aria-label="Min" class="form-control" />
            <input v-model="price_max" placeholder="Max" aria-label="Max" class="form-control" />
          </div>
        </div>
          <div class="row pt-3">
          <label>除外ワード</label>
          <div class="input-group">
            <input v-model="negative_keyword" placeholder="〜を含まない" aria-label="Min" class="form-control" />
          </div>
        </div>
        <div class="row">
          <div class="form-check">
            <input v-model="include_title_flag" class="form-check-input" type="checkbox" value="" id="flexCheckDefault">
            <label class="form-check-label" for="flexCheckDefault" style="font-size:0.9rem">
              タイトルに検索ワードを含む
            </label>
          </div>
         </div>

      </div>
      <div class="col">
        <div v-if="isLoading">
          読み込み中...
        </div>
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
    // let cron_flag = ref(false)
    let sale_array = ref([])
    let sold_array = ref([])
    let data_array = ref([])
    let label_array = ref([])
    let items = ref([])
    let isLoading = ref(false)

    const updateChart = async () => {
      if (keyword.value) {
        isLoading.value = true
        let params = {
          keyword: keyword.value,
          price_min: price_min.value,
          price_max: price_max.value,
          negative_keyword: negative_keyword.value,
          include_title_flag: include_title_flag.value
        }
        let query = new URLSearchParams(params)
        sale_array.value = []
        sold_array.value = []
        data_array.value = []
        label_array.value = []
        items.value = []
        await fetch(`/api/v1/items?${query}`)
          .then((response) => {
            if (!response.ok) {
              throw new Error(`item not found (${response.status})`)
            }
            return response.json()
          })
          // ここでjson形式のdataになる
          .then((json) => {
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
            items.value = json['items']
            isLoading.value = false
          })

        resetFlag.value = true
        resetKey.value++
      } else {
        resetFlag.value = false
      }
    }

    const postChart = async () => {
        let params = {
          keyword: keyword.value,
          price_min: price_min.value,
          price_max: price_max.value
        }
      // await fetch(`/api/v1/items?${query}`)
      fetch('/search_conditions', {
      method: 'POST',
      credentials: 'same-origin',
      headers: {
                'Content-Type': 'application/json',
                'X-CSRF-Token': getCsrfToken()
      },
      body: JSON.stringify(params),
    })
    .then(function(response){
      const response_message = response.status + ':' + response.statusText
      console.log(response_message);
      window.alert('response_message=' + response_message);
    });
    }

    const getCsrfToken = () => {
      const metas = document.getElementsByTagName('meta');
      for (let meta of metas) {
          if (meta.getAttribute('name') === 'csrf-token') {
              console.log('csrf-token:', meta.getAttribute('content'));
              return meta.getAttribute('content');
          }
      }
      return '';
  }

    return {
      updateChart,
      postChart,
      keyword,
      price_min,
      price_max,
      negative_keyword,
      include_title_flag,
      // cron_flag,
      resetFlag,
      resetKey,
      sale_array,
      sold_array,
      data_array,
      label_array,
      items,
      isLoading
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
</style>