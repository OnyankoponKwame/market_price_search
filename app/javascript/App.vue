<template>

  <Suspense>
    <ScatterChart />
  </Suspense>
  
  <Search />
</template>

<script>
import ScatterChart from './src/scatterChart'
import Search from './Search'
export default {
  name: 'App',
  components: {
    Search,
  }
}
</script>