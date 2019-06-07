import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Headersetter } from '../data/headersetter';

@Injectable({
  providedIn: 'root'
})
export class AttributeValueService {

  private service="/attributeValue";

  constructor(private _http:HttpClient,
              private _headerSetter:Headersetter) { }

  /* Urls for all category related apis */ 

  private allAttributeValuesUrl=this._headerSetter.baseUrl+this.service+"/getAllAttributes";
  private getDepartmentUrl=this._headerSetter.baseUrl+this.service+"/getAttributeTypes";
  private countAllAttributeValuesUrl=this._headerSetter.baseUrl+this.service+"/countAttributes";
  private addAttributeValueUrl=this._headerSetter.baseUrl+this.service+"/addAttribute";
  private updateAttributeValueUrl=this._headerSetter.baseUrl+this.service+"/updateAttributeValue";
  private deleteCategoryUrl=this._headerSetter.baseUrl+this.service+"/deleteCategory";
  private searchAttributeValueUrl=this._headerSetter.baseUrl+this.service+"/searchAttributeValue";
  private getValuesByAttributeUrl=this._headerSetter.baseUrl+this.service+"/getValuesByAttribute";

  /* Calls api for getting attribute's values for listing */

  getAllAttributes(up){
    let options=this._headerSetter.getHeader();
    return this._http.get<any>(this.allAttributeValuesUrl+"/"+up,options);
  }

  /* Calls api for getting all attrribute types */

  getDepartments(){
    let options=this._headerSetter.getHeader();
    return this._http.get<any>(this.getDepartmentUrl,options);
  }

  /* Calls api for counting the attribute's values */

  countAttributes(){
    let options=this._headerSetter.getHeader();
    return this._http.get<any>(this.countAllAttributeValuesUrl,options);
  }

  /* Calls api for adding the attribute value into database */

  addAttribute(attribute){
    let options=this._headerSetter.getHeader();
    return this._http.post<any>(this.addAttributeValueUrl,attribute,options);
  }

  /* Calls api for updating the attribute value into the database */

  updateAttribute(attribute){
    let options=this._headerSetter.getHeader();
    return this._http.post<any>(this.updateAttributeValueUrl,attribute,options);
  }

  /* Calls api for delete the attribute value */

  deleteAttribute(attribute){
    let options=this._headerSetter.getHeader();
    return this._http.post<any>(this.deleteCategoryUrl,attribute,options);
  }

  /* Calls api for search the attribute values */

  searchAttributeValue(key){
    let options=this._headerSetter.getHeader();
    return this._http.get<any>(this.searchAttributeValueUrl+"/"+key,options);
  }

  /* Calls api for get attrbuite's value by giving specific attribute's id */

  getValuesByAttribute(attribute_id){
    let options=this._headerSetter.getHeader();
    return this._http.get<any>(this.getValuesByAttributeUrl+"/"+attribute_id,options);
  }
}
