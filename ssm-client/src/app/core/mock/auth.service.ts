import { Injectable } from '@angular/core';
import { HttpClient, HttpHeaders } from '@angular/common/http';
import { Router } from '@angular/router';
import { HeaderSetter } from '../data/header-setter';

@Injectable({
  providedIn: 'root'
})
export class AuthService {

  constructor(private _http:HttpClient,private _router:Router,private headerSetter:HeaderSetter) { }

  /* Urls of all authentication & Authorization related apis  */

  private _loginUrl=this.headerSetter.baseUrl+"/authentication/loginUser";
  private _registerUrl=this.headerSetter.baseUrl+"/authentication/registerUser";
  private _getUserUrl=this.headerSetter.baseUrl+"/authentication/getUserDetail";
  private _getCartDataUrl=this.headerSetter.baseUrl+"/cart/countCartItem";
  private _getWishlistDataUrl=this.headerSetter.baseUrl+"/cart/countWishlistItem";

  /* Call login api */

  loginUser(user){
    return this._http.post<any>(this._loginUrl,user);
  }

  /* Call register api */

  registerUser(user){
    return this._http.post<any>(this._registerUrl,user);
  }

  /* Checking for JWT in localstorage for checking user is logged in or not */

  loggedIn(){
    return !!localStorage.getItem('token');
  }

  /* Return the JWT Token from local storage of client */

  getToken(){
    return localStorage.getItem('token');
  }

  /* Remove token from client's local storage when user logged out */

  loggedOut(){
    localStorage.removeItem('token');
    this._router.navigate(['/']);
  }

  /* Call get user detail api */

  getUser(){
    let options=this.headerSetter.getHeader();
    return this._http.get<any>(this._getUserUrl,options);
  }
  
  /* Call get cart data of perticular user api */ 

  getCartData(){
    let options=this.headerSetter.getHeader();
    return this._http.get<any>(this._getCartDataUrl,options);
  }

 /* Call get wishlist data of perticular user api */ 

  getWishlistData(){
    let options=this.headerSetter.getHeader();
    return this._http.get<any>(this._getWishlistDataUrl,options);
  }
}
