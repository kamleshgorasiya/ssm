import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Router } from '@angular/router';
import { Headersetter } from '../data/headersetter';

@Injectable({
  providedIn: 'root'
})
export class AuthService {

  private service="/authentication";
  constructor(private _http:HttpClient,
              private _router:Router,
              private _headerSetter:Headersetter) { }

  /* Urls of all authentication & Authorization related apis  */

  private _loginUrl=this._headerSetter.baseUrl+this.service+"/loginUser";
  private _getUserUrl=this._headerSetter.baseUrl+this.service+"/getUser";

  /* Call login api */

  loginUser(user){
    return this._http.post<any>(this._loginUrl,user);
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
      let options=this._headerSetter.getHeader();
      return this._http.get<any>(this._getUserUrl,options);
    }
}
