import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';  
import { HeaderSetter } from '../data/header-setter';

@Injectable({
  providedIn: 'root'
})
export class PaymentService {


  constructor(private _http:HttpClient,private headerSetter:HeaderSetter) { }

   /* Urls of all Payment related apis  */

  private checkoutUrl=this.headerSetter.baseUrl+"/payment/checkout";

  /* Call api for confirming payment and place the order */
  
  paymentcheckOut(details){
    let options=this.headerSetter.getHeader();
    return this._http.post<any>(this.checkoutUrl,details,options);
  }

  
}
