<template>
  <div class="search">
      <p> {{ keyword }} </p>
      <input v-bind="keyword" >
      <!-- <input v-bind="keyword" v-on:keydown.enter="updateName($event.target.value)"> -->
      <button v-on:click="updateName()">検索</button>
  </div>
  <Suspense>
    <ScatterChart />
  </Suspense>
</template>

<script>
import { ref } from 'vue'
import axios from 'axios'
import ScatterChart from './src/scatterChart'

export default {
  components: {
    ScatterChart
  },
  setup(props, context) {
    const message = ref("Hello World");
    const items = ref([]);
    const keyword = ref();

    function updateName(value) {
      let queries = {keyword: keyword}
      // context.emit('update:name', value) // 変更イベントを発生
                  //axiosのgetメソッドでAPIをたたく
            axios.get('/api/v1/items.json', {params: queries})
                .then(function(res){
                    console.log(res)　//データ取得できたか確認用
                    this.item = res.data //itemプロパティに取得データを格納
                })
            //エラー発生時の処理
            .catch(function(error){
                // this.message = 'Error!' + error
            })
    }

    return {
      message,
      items,
      search,
      updateName
    };
  },
}
</script>