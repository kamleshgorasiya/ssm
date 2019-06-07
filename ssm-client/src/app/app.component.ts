import { Component } from '@angular/core';


@Component({
  selector: 'app-root',
  templateUrl: './app.component.html',
  styleUrls: ['./app.component.css']
})
export class AppComponent {
  
  
  constructor(){
    // interval(10000).subscribe(()=>updates.checkForUpdate());
    // updates.available.subscribe(event=>{
    //   if(prompt('Update available for this app. Do you want to update it?')){
    //     updates.activateUpdate().then(()=>document.location.reload());
    //   }
    // });
    // updates.activated.subscribe(event=>{
    //   console.log('old version was',event.previous);
    //   console.log('new version is',event.current);
    // })
    // Notification.requestPermission(status=>{
    //   console.log('Notification permission status :',status);
    // });
    // navigator.serviceWorker.getRegistration().then(reg=>{
    //   reg.showNotification('hello world');
    // })
  //   window.addEventListener('beforeinstallprompt', event => {
  //     this.promptEvent = event;
  //   });
  // }
  // installPwa(): void {
  //   this.promptEvent.prompt();
  }
}
