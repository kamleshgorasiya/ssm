import { Injectable } from '@angular/core';
import { HeaderSetter } from '../data/header-setter';
import { HttpClient } from '@angular/common/http';

@Injectable({
  providedIn: 'root'
})
export class OrderService {

   /* Urls of all Order related apis  */

  private oredrDetailUrl=this.headerSetter.baseUrl+"/payment/orderDetail";
  private cancelUrl=this.headerSetter.baseUrl+"/payment/cancelOrder";

  constructor(private headerSetter:HeaderSetter,private _http:HttpClient) { }

  /* Call api for getting orders of perticular order */

  getOrders(){
    let options=this.headerSetter.getHeader();
    return this._http.get<any>(this.oredrDetailUrl,options);
  }

  /* Call api for canceling order */
  
  cancelOrder(order){
    let options=this.headerSetter.getHeader();
    return this._http.post<any>(this.cancelUrl,order,options);
  }
}
