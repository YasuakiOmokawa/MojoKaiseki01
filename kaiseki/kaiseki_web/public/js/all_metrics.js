/* 
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */

var updater = false;

function main(){
    if(!updater){
        updater = new Ajax.PeriodicalUpdater( 'all_metrics', 'datas/all_metrics.html');
        updater.start();
    }
    
}

