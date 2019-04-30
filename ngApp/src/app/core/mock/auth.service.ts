import { Injectable } from '@angular/core';
import { HttpClient, HttpHeaders } from '@angular/common/http';
import { Router } from '@angular/router';

@Injectable({
  providedIn: 'root'
})
export class AuthService {

  constructor(private _http:HttpClient,private _router:Router) { }

  private _loginUrl="http://localhost:3000/authentication/loginUser";
  private _registerUrl="http://localhost:3000/authentication/registerUser";
  private _getUserUrl="http://localhost:3000/authentication/getUserDetail";
  private _getCartDataUrl="http://localhost:3000/cart/countCartItem";
  private _getWishlistDataUrl="http://localhost:3000/cart/countWishlistItem";

  loginUser(user){
    return this._http.post<any>(this._loginUrl,user);
  }
  registerUser(user){
    return this._http.post<any>(this._registerUrl,user);
  }
  loggedIn(){
    return !!localStorage.getItem('token');
  }
  getToken(){
    return localStorage.getItem('token');
  }
  loggedOut(){
    localStorage.removeItem('token');
    this._router.navigate(['/']);
  }
  getUser(){
    let headers=new HttpHeaders({
      'Authorization':`Bearer ${this.getToken()}`
    })
    let options={headers:headers};
    return this._http.get<any>(this._getUserUrl,options);
  }
  
  getCartData(){
    let headers=new HttpHeaders({
      'Authorization':`Bearer ${this.getToken()}`
    })
    let options={headers:headers};
    return this._http.get<any>(this._getCartDataUrl,options);
  }

  getWishlistData(){
    let headers=new HttpHeaders({
      'Authorization':`Bearer ${this.getToken()}`
    })
    let options={headers:headers};
    return this._http.get<any>(this._getWishlistDataUrl,options);
  }
}
