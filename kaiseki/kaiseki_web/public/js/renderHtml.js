/* 
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */

var updater = false;

function main(){
    if(!updater){
        updater = new Ajax.PeriodicalUpdater( 
                'tbl_all_metrics',
                'datas/tbl_all_metrics.html',
                {
                    onSuccess: function(request) {
                        var str = updater.options.parameters;
                        var hash = str.parseQuery();
                        hash["ajax_request_id"] = Math.random();
                        hash = $H(hash);
                        updater.options.parameters = hash.toQueryString();
                   }
                }
        );
        updater.start();
    }
    
}

