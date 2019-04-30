import { Injectable } from '@angular/core';
import { Subject } from 'rxjs';
import { User } from '../data/user';
import { TouchSequence } from 'selenium-webdriver';

@Injectable({
  providedIn: 'root'
})
export class DataExchangeService {

  private messageSource=new Subject<number>();
  private userName=new Subject<User>();
  private addCart=new Subject<string>();
  private addWishlist=new Subject<string>();
  private searchItem=new Subject<string>();
  private addressItem=new Subject<string>();

  userMessage$=this.userName.asObservable();
  currentmessage$=this.messageSource.asObservable();
  addCartMessage$=this.addCart.asObservable();
  addWishlistMessage$=this.addWishlist.asObservable();
  searchMessage$=this.searchItem.asObservable();
  addressMessage$=this.addressItem.asObservable();

  constructor() { }
  changeCategory(categoryId){
    this.messageSource.next(categoryId);
  }

  changeUserName(user){
    this.userName.next(user);
  }

  changeCartData(cartData){
    this.addCart.next(cartData);
  }

  changeWishlistData(wishlistData){
    this.addWishlist.next(wishlistData);
  }

  changeSearchData(searchData){
    this.searchItem.next(searchData);
  }

  changeAddress(address){
    this.addressItem.next(address);
  }
}
