import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { HttpHeaders } from '@angular/common/http';
import { AuthService } from './auth.service';

@Injectable({
  providedIn: 'root'
})
export class PaymentService {


  constructor(private _http:HttpClient,private  _authService: AuthService) { }

  private checkoutUrl="http://localhost:3000/payment/checkout";
  private oredrDetailUrl="http://localhost:3000/payment/orderDetail";

  setHeader():any{
    let headers=new HttpHeaders({
      'Authorization':`Bearer ${this._authService.getToken()}`
    })
    let options={headers:headers};
    return options;
  } 

  paymentcheckOut(details){
    let options=this.setHeader();
    console.log(details)
    return this._http.post<any>(this.checkoutUrl,details,options);
  }

  getOrders(){
    let options=this.setHeader();
    return this._http.get<any>(this.oredrDetailUrl,options);
  }
}
