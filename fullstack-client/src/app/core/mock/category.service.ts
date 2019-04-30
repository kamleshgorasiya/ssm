import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';

@Injectable({
  providedIn: 'root'
})
export class CategoryService {

  private categoryUrl="http://localhost:3000/product/category";
  private departmentUrl="http://localhost:3000/product/department";
  constructor(private _http:HttpClient) { }
  getCategory(){
    return this._http.get<any>(this.categoryUrl);
  }
  getDepartment(){
    return this._http.get<any>(this.departmentUrl);
  }
}
