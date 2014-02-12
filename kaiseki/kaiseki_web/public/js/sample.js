var updater = false;
var started = false;

function main(){

    if(!updater){
    
        updater = new Ajax.PeriodicalUpdater(
        
            {
//  ■ success
//  成功した場合に更新される要素
                success         : 'all_metrics',

//  ■ failure
//  失敗した場合に更新される要素
                failure         : 'id_failure'
            },

            'datas/all_metrics.html',    //  ここに URL を記載
         
            {
//  ■ decay
//  更新頻度の減衰率。デフォルトは 1。
                decay           : 1.1,

//  ■ frequency
//  更新頻度(秒)。デフォルトは 2。
                frequency       : 2,

//  ■ method
//  'get' か 'post' を設定する。無ければデフォルトの 'post' でいく。
                method          : 'get',
                
//  ■ asynchronous
//  リクエストの通知が同期か非同期かの設定。true は非同期、false は同期。
//  無ければデフォルトの true で行く。
//  同期とは、リクエストが帰ってくるまで、スクリプトを止めるってこと。
                asynchronous    : true,

//  ■ requestHeaders
//  追加するヘッダを書く、key, value ,key, value と交互に書きましょう♪
                requestHeaders  : ['X-Header-0', 'Value0', 'X-Header-1', 'Value1'],

//  ■ postBody
//  'post' でリクエストする場合はこのデータが送られる。
//  未設定の場合は parameters のデータが送られる。
//                postBody        : $H({name:'天野', hobby:'勉強'}).toQueryString(),

//  ■ parameters
//  'get' でリクエストする場合はこのデータが送られる。
//  'post' でも、postBody が未設定の場合はこのデータが送られる。
//                parameters      : $H({name:'天野', hobby:'勉強'}).toQueryString(),

//  ■ onXxxx()
//  引数 req は XMLHttpRequest のインスタンスが入る。
//  引数 json にはレスポンスヘッダ X-JSON の値から生成したオブジェクトが入る。
//  また、onSuccess や onFailure は「200 OK」などの status によって判定される。
//  もっと詳しいイベントを取得したい場合、on503 on200 on404 などの関数を実装すればよい。 

                onUninitialized : function(req, json){
                },
                onLoading       : function(req, json){
                },
                onLoaded        : function(req, json){
                },
                onInteractive   : function(req, json){
                },
                onComplete      : function(req, json){
                },
                onSuccess       : function(req, json){
                },
                onFailure       : function(req, json){
                },    

//  ■ onException()
//  上記の onXxxx 関数群で throw された場合に実行される。
//  e は throw されたオブジェクト
                onException     : function(request, e){
                    alert(e.name + ': '+ e.message);
                }
            }
        );
        started = true;
        $('action').value = 'stop';
    }
    else{
        if(started){
            $('action').value = 'start';

            //  ストップで止める。
            updater.stop();
            started = false;
        }
        else{

            //  スタートで再開。
            updater.start();
            $('action').value = 'stop';
            started = true;
        }
    }
}

