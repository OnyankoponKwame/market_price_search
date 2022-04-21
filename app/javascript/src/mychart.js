import { Chart } from 'chart.js';
document.addEventListener('turbolinks:load', () => {

  const hash = document.getElementById('hash').value;
  var json = JSON.parse(hash);
  var data = [];
  for (const elem of json) {
    var x = elem[0];
    var y = elem[1];
    data.push( { x:x, y:y });
  };

  const hash2 = document.getElementById('hash2').value;
  var json2 = JSON.parse(hash2);
  var data2 = [];
  for (const elem of json2) {
    var x = elem[0];
    var y = elem[1];
    data2.push( { x:x, y:y });
  };



  // チャートのデータ
  const scatterChartData = {
    datasets: [{
      label: 'Group1',
      data: data,
      backgroundColor: 'rgba(0, 159, 255, 0.45)'
    },{
      label: 'Group2',
      data: data2,
      backgroundColor: 'rgba(255, 48, 32, 0.45)'
    }
  ],
  };

  const scatterChartOption = {
    scales: {
      x: {
        scaleLabel: {
          display: true,
          labelString: '時間'
        },
        type: 'time',
        time: {
          parser: 'YYYY-MM-DD',
          unit: 'day',
          stepSize: 1,
          displayFormats: {
            'hour': 'H時'
          }
        }
      }
    }
  };

  //チャートを表示
  const scatterChartContext = document.getElementById('scatter-chart').getContext('2d');
  new Chart(scatterChartContext, {
    type: 'scatter',
    data: scatterChartData,
    options: scatterChartOption
  });

});

