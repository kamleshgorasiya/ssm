import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Headersetter } from '../data/headersetter';

@Injectable({
  providedIn: 'root'
})
export class OrderService {

  private service="/order/";
  constructor(private _http:HttpClient,
              private _headerSetter:Headersetter) { }

  /* All apis links related to Manage-Order */
  
  private getPendingOrderUrl=this._headerSetter.baseUrl+this.service+"getPendingOrder";
  private countPendingOrderUrl=this._headerSetter.baseUrl+this.service+"countPendingOrder";
  private confimOrderUrl=this._headerSetter.baseUrl+this.service+"confirmOrder";
  private getConfirmedOrderUrl=this._headerSetter.baseUrl+this.service+"getConfirmedOrder";
  private countConfirmedOrderUrl=this._headerSetter.baseUrl+this.service+"countConfirmedOrder";
  private dispatchOrderUrl=this._headerSetter.baseUrl+this.service+"dispatchOrder";
  private getDispatchedOrderUrl=this._headerSetter.baseUrl+this.service+"getDispatchedOrder";
  private countDispatchedOrderUrl=this._headerSetter.baseUrl+this.service+"countDispatchedOrder";
  private deliverOrderUrl=this._headerSetter.baseUrl+this.service+"deliverOrder";
  private getDeliveredOrderUrl=this._headerSetter.baseUrl+this.service+"getDeliveredOrder";
  private countDeliveredOrderUrl=this._headerSetter.baseUrl+this.service+"countDeliveredOrder";



  /* Calls api for getting all products list within page-limit */

  getPendingOrder(up){
    let options=this._headerSetter.getHeader();
    return this._http.get<any>(this.getPendingOrderUrl+"/"+up,options);
  }

  /* Calls api for count pending orders of particular user */

  countPendingOrder(){
    let options=this._headerSetter.getHeader();
    return this._http.get<any>(this.countPendingOrderUrl,options);
  }

  /* Calls api for confirming Order */

  confirmOrder(item_id){
    let options=this._headerSetter.getHeader();
    return this._http.post<any>(this.confimOrderUrl,{item_id:item_id},options);
  }

    /* Calls api for getting all products list within page-limit */

    getConfirmedOrder(up){
      let options=this._headerSetter.getHeader();
      return this._http.get<any>(this.getConfirmedOrderUrl+"/"+up,options);
    }
  
    /* Calls api for count pending orders of particular user */
  
    countConfirmedOrder(){
      let options=this._headerSetter.getHeader();
      return this._http.get<any>(this.countConfirmedOrderUrl,options);
    }
  
    /* Calls api for confirming Order */
  
    dispatchOrder(item_id){
      
      let options=this._headerSetter.getHeader();
      return this._http.post<any>(this.dispatchOrderUrl,{item_id:item_id},options);
    }
      /* Calls api for getting all products list within page-limit */

  getDispatchedOrder(up){
    let options=this._headerSetter.getHeader();
    return this._http.get<any>(this.getDispatchedOrderUrl+"/"+up,options);
  }

  /* Calls api for count dispatched orders of particular user */

  countDispatchedOrder(){
    
    let options=this._headerSetter.getHeader();
    return this._http.get<any>(this.countDispatchedOrderUrl,options);
  }

  /* Calls api for Deliver Order */

  deliverOrder(item_id){
    let options=this._headerSetter.getHeader();
    return this._http.post<any>(this.deliverOrderUrl,{item_id:item_id},options);
  }

  /* Calls api for getting data of delivered product */ 

  getDeliveredOrder(up){
    let options=this._headerSetter.getHeader();
    return this._http.get<any>(this.getDeliveredOrderUrl+"/"+up,options);
  }

  /* Calls api for count pending orders of particular user */

  countDeliveredOrder(){
    let options=this._headerSetter.getHeader();
    return this._http.get<any>(this.countDeliveredOrderUrl,options);
  }
}
