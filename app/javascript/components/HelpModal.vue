<template>
  <button @click="modalOpen = true" class="btn btn-outline-secondary">Help</button>

  <teleport to="body">
    <div v-if="modalOpen" class="modal" @click="modalOpen = false">
      <div>
        <h2 class="modal-title text-center">使い方</h2>
        検索条件を入力の上検索を押してください。価格推移、価格散布図、直近で売れた価格のヒストグラムがグラフで表示されます。
        <br />
        <br />
        検索条件が入力された状態で定期実行登録ボタンを押すと、指定した検索条件で毎日1回データが収集され、価格推移を見ることができます。
        <br />
        <br />
        <button @click="modalOpen = false" class="btn btn-secondary">閉じる</button>
      </div>
    </div>
  </teleport>
</template>
 
<script>
export default {
  name: 'HelpModal',
  data() {
    return {
      modalOpen: true
    }
  }
}
</script>
 
<style scoped>
.modal {
  background-color: rgba(0, 0, 0, 0.5);
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
}

.modal div {
  position: fixed;
  top: 10%;
  display: flex;
  flex-direction: column;
  background-color: white;
  padding: 20px;
  transition: opacity 200ms linear;
  border-radius: 6px;
  min-width: 300px;
  max-width: 70vh;
  max-height: 90vh;
  overflow-wrap: normal;
}
.modal-title {
  border-bottom: 1px solid #dedede;
  align-items: center;
  font-size: 1.25rem;
  margin: 0 0 1.5rem 0;
  padding-bottom: 0.5rem;
}
</style>
