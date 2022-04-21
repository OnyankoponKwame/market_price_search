<template>
  <div class="search">
    <v-text-field type="text" v-model="keyword" label="検索"></v-text-field>
  </div>
  <Suspense>
    <ScatterChart />
  </Suspense>
</template>

<script>
import ScatterChart from './src/scatterChart'
export default {
  name: 'App',
  components: {
    ScatterChart
  }
}
</script>