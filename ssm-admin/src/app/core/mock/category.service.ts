import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Headersetter } from '../data/headersetter';

@Injectable({
  providedIn: 'root'
})
export class CategoryService {

  private service="/category";

  constructor(private _http:HttpClient,
              private _headerSetter:Headersetter) { }

  /* Urls for all category related apis */ 

  private allCategoryUrl=this._headerSetter.baseUrl+this.service+"/getAllCategory";
  private getDepartmentUrl=this._headerSetter.baseUrl+this.service+"/getDepartments";
  private countCategoryUrl=this._headerSetter.baseUrl+this.service+"/countCategory";
  private addCategoryUrl=this._headerSetter.baseUrl+this.service+"/addCategory";
  private updateCategoryUrl=this._headerSetter.baseUrl+this.service+"/updateCategory";
  private activateCategoryUrl=this._headerSetter.baseUrl+this.service+"/activateCategory";
  private deleteCategoryUrl=this._headerSetter.baseUrl+this.service+"/deleteCategory";
  private changeAllCategoryStatusUrl=this._headerSetter.baseUrl+this.service+"/changeAllCategoryStatus";
  private searchCategoryUrl=this._headerSetter.baseUrl+this.service+"/searchCategory";
  private categoryByDepartmentUrl=this._headerSetter.baseUrl+this.service+"/categoryByDepartment";
  private getAllCategoriesByDepartmentUrl=this._headerSetter.baseUrl+this.service+"/getCategoriesByDepartment";

  /* Calls api for getting categories for listing */

  getAllCategory(up){
    let options=this._headerSetter.getHeader();
    return this._http.get<any>(this.allCategoryUrl+"/"+up,options);
  }

  /* Calls api for getting all departments */

  getDepartments(){
    let options=this._headerSetter.getHeader();
    return this._http.get<any>(this.getDepartmentUrl,options);
  }

  /* Calls api for counting the categories */

  countCategories(){
    let options=this._headerSetter.getHeader();
    return this._http.get<any>(this.countCategoryUrl,options);
  }

  /* Calls api for adding the category into database */

  addCategory(category){
    let options=this._headerSetter.getHeader();
    return this._http.post<any>(this.addCategoryUrl,category,options);
  }

  /* Calls api for updating the category into the database */

  updateCategory(category){
    let options=this._headerSetter.getHeader();
    return this._http.post<any>(this.updateCategoryUrl,category,options);
  }

  /* Calls api for activate/ deactivate the category */

  activateCategory(category){
    let options=this._headerSetter.getHeader();
    return this._http.post<any>(this.activateCategoryUrl,category,options);
  }

  /* Calls api for delete the category */

  deleteCategory(category){
    let options=this._headerSetter.getHeader();
    return this._http.post<any>(this.deleteCategoryUrl,category,options);
  }

  /* Calls api for enable or disable all the category */

  changeAllCategoryStatus(category){
    let options=this._headerSetter.getHeader();
    return this._http.post<any>(this.changeAllCategoryStatusUrl,category,options);
  }

  /* Calls api for searching category with page limit */

  searchCategory(data){
    let options=this._headerSetter.getHeader();
    return this._http.get<any>(this.searchCategoryUrl+"/"+data.key+"/"+data.up,options);
  }

  /* Calls api for getting categories by giving department_id with page limit */

  getCategoryByDepartmentId(data){
    let options=this._headerSetter.getHeader();
    return this._http.get<any>(this.categoryByDepartmentUrl+"/"+data.department_id+"/"+data.up,options);
  }

  /* Calls api for getting all categories of perticular department */

  getCategoriesOfDepartment(department_id){
    let options=this._headerSetter.getHeader();
    return this._http.get<any>(this.getAllCategoriesByDepartmentUrl+"/"+department_id,options);
  }
}
