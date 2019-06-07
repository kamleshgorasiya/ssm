import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { HeaderSetter } from '../data/header-setter';

@Injectable({
  providedIn: 'root'
})
export class CategoryService {

  /* Urls of all authentication & Authorization related apis  */

  private categoryUrl=this.headerSetter.baseUrl+"/product/category";
  private departmentUrl=this.headerSetter.baseUrl+"/product/department";

  constructor(private _http:HttpClient,private headerSetter:HeaderSetter) { }

  /* Call api for getting all categories */

  getCategory(){
    return this._http.get<any>(this.categoryUrl);
  }

  /* Call api for gettig all departments */
  
  getDepartment(){
    return this._http.get<any>(this.departmentUrl);
  }
}
