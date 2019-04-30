import { Injectable } from '@angular/core';
import { AuthService } from './auth.service';
import { HttpClient, HttpHeaders } from '@angular/common/http';

@Injectable({
  providedIn: 'root'
})
export class CartService {

  private addToBagUrl="http://localhost:3000/cart/addToBag";
  private addToWishListUrl="http://localhost:3000/cart/addToWishList"
  private addLocalBagsUrl="http://localhost:3000/cart/addLocalBags";
  private getCartProductsUrl="http://localhost:3000/cart/getCartProducts";
  private moveToWishlistUrl="http://localhost:3000/cart/moveToWishlist";
  private removeCartUrl="http://localhost:3000/cart/removeCart";
  private updateQuantityUrl="http://localhost:3000/cart/updateQuantity";
  private getWishlistProductsUrl="http://localhost:3000/cart/getWishlistProduct";
  private checkWishListUrl="http://localhost:3000/cart/checkWishlist";
  private removeWishlistUrl="http://localhost:3000/cart/removeWishlist";
  private addToBagWishlistUrl="http://localhost:3000/cart/addToBagWishlist";

  constructor(private _http:HttpClient,private _authService:AuthService) { }

  setHeader():any{
    let headers=new HttpHeaders({
      'Authorization':`Bearer ${this._authService.getToken()}`
    })
    let options={headers:headers};
    return options;
  }

  addToBag(cart){
    let headers=new HttpHeaders({
      'Authorization':`Bearer ${this._authService.getToken()}`
    })
    let options={headers:headers};
    return this._http.post<any>(this.addToBagUrl,cart,options);
  }
  addToWishlist(wishlist){
    let headers=new HttpHeaders({
      'Authorization':`Bearer ${this._authService.getToken()}`
    })
    let options={headers:headers};
    return this._http.post<any>(this.addToWishListUrl,wishlist,options);
  }
  addLocalBags(products){
    let headers=new HttpHeaders({
      'Authorization':`Bearer ${this._authService.getToken()}`
    })
    let options={headers:headers};
    return this._http.post<any>(this.addLocalBagsUrl,products,options);
  }
  getCartProducts(){
    let headers=new HttpHeaders({
      'Authorization':`Bearer ${this._authService.getToken()}`
    })
    let options={headers:headers};
    return this._http.get<any>(this.getCartProductsUrl,options);
  }
  moveToWishlist(cart){
    let headers=new HttpHeaders({
      'Authorization':`Bearer ${this._authService.getToken()}`
    })
    let options={headers:headers};
    return this._http.post<any>(this.moveToWishlistUrl,cart,options);
  }
  removeCart(cart){
    let headers=new HttpHeaders({
      'Authorization':`Bearer ${this._authService.getToken()}`
    })
    let options={headers:headers};
    return this._http.post<any>(this.removeCartUrl,cart,options);
  }
  updateQuantity(cart){
    let headers=new HttpHeaders({
      'Authorization':`Bearer ${this._authService.getToken()}`
    })
    let options={headers:headers};
    return this._http.post<any>(this.updateQuantityUrl,cart,options);
  }
  getWishlistProduct(){
    let headers=new HttpHeaders({
      'Authorization':`Bearer ${this._authService.getToken()}`
    })
    let options={headers:headers};
    return this._http.get<any>(this.getWishlistProductsUrl,options);
  }
  checkWishlist(wishlist){
    let options=this.setHeader();
    return this._http.post<any>(this.checkWishListUrl,wishlist,options);
  }
  removeWishlist(wishlist){
    let options=this.setHeader();
    return this._http.post<any>(this.removeWishlistUrl,wishlist,options);
  }
  addToBagWishList(product){
    let options=this.setHeader();
    return this._http.post<any>(this.addToBagWishlistUrl,product,options);
  }
}
