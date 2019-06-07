import { Component, OnInit } from '@angular/core';
import { AttributeValueService } from 'src/app/core/mock/attribute-value.service';
import { AuthService } from 'src/app/core/mock/auth.service';
import { Router } from '@angular/router';

@Component({
  selector: 'app-attribute-list',
  templateUrl: './attribute-list.component.html',
  styleUrls: ['./attribute-list.component.css']
})
export class AttributeListComponent implements OnInit {

  constructor(private _attributeService:AttributeValueService,
              private _authService:AuthService,
              private _router:Router) { }

  attributes=new Array();
  totalAttributes;
  attributeAdd={
    attribute_value_id:0,
    value:"",
    attribute_id:0
  };
  btnStatus=0;
  displayLimit=10;
  departments=new Array();
  currentPage=1;
  lastPage;
  sorting=0;
  sortKey=0;
  search="";
  searchedAttribute=new Array();
  displayPages=new Array();
  attributeDepartment=new Array();
  departmentErrorText="";
  selectedAttribute={
    attribute_id:0,
    name:"Select the Attribute",
    description:""
  }
  filterAttribute={
    attribute_id:0,
    name:"Select the Attribute",
    description:""
  }

  ngOnInit() {

    // If user is not logged in,it will redirect to login page

    if(!this._authService.loggedIn()){
      this._router.navigate(['']);
    }
    this._attributeService.countAttributes()
    .subscribe(
      res=>{
        this.totalAttributes=res[0].countAttribute;
        let totalPages=this.totalAttributes/this.displayLimit;
        this.setPagination(totalPages);
      }
    )
    this._attributeService.getAllAttributes(0)
    .subscribe(
      res=>{
        // @ts-ignore
        this.attributes=res;
        this._attributeService.getDepartments()
        .subscribe(
          res=>{
            // @ts-ignore
            this.departments=res;
          }
        )
      }
    );
  }

  selectDepartment(department){
    this.selectedAttribute=department;
    if(this.selectedAttribute.attribute_id!=0){
      this.departmentErrorText="";
    } 
  }

  setPagination(totalPages){
    delete this.displayPages;
    this.displayPages=new Array();
    
    totalPages=Math.ceil(totalPages);
    this.lastPage=totalPages;
    let startPage;
    if(this.currentPage>5 && this.currentPage<this.lastPage-5){
      startPage=this.currentPage-5;
      for(let i=0;i<this.currentPage+5;i++){
        this.displayPages.push(startPage);
        startPage=startPage+1;
      }
    } else {
      if(this.currentPage<5){
        for(let i=0;i<10;i++){
          this.displayPages.push(i+1);
          if(i+1==this.lastPage){
            break;
          }
        }
      } else {
        for(let i=this.lastPage-10;i<=this.lastPage;i++){
          if(i>0){
            this.displayPages.push(i);
          }
          
        }
      }
    }
  }

  changePage(pageno){
    this.currentPage=pageno;
    if(this.search==""){
      if(this.filterAttribute.attribute_id!=0){
        this.setSerachedAttributes(pageno);
      } else {
        this._attributeService.getAllAttributes((pageno*10)-10)
        .subscribe(
          res=>{
            // @ts-ignore
            this.attributes=res; 
          }
        )
      }
      
    } else {
      this.setSerachedAttributes(pageno);
    }
    
  }

  /* add Category to database */

  addCategory(){
    if(this.selectedAttribute.attribute_id==0)
    {
      this.departmentErrorText="Select the appropriate Attribute type";
    } else {
      if(this.attributeAdd.value.length>0){
        this.attributeAdd.attribute_id=this.selectedAttribute.attribute_id;
        this._attributeService.addAttribute(this.attributeAdd)
        .subscribe(
          res=>{
            window.alert("Attributes value is added successfully");
          }
        )
      } else {
        window.alert("Enter the value of Attributes");
      }
    }
  }

  /* Update Category to database */

  updateCategory(){
    if(this.selectedAttribute.attribute_id==0)
    {
      this.departmentErrorText="Select the appropriate attribute type";
    } else {
      if(this.attributeAdd.value.length>0){
        this.attributeAdd.attribute_id=this.selectedAttribute.attribute_id;
        this._attributeService.updateAttribute(this.attributeAdd)
        .subscribe(
          res=>{
            window.alert("Attribute value updated successfully");
          }
        )
      } else {
        window.alert("Enter attribute value");
      }
    }
  }

  /* cancel the add category */

  cancelCategory(){
    this.attributeAdd.value="";
    this.btnStatus=0;
  }

  /* Edit the category */

  editCategory(attribute){
    this.attributeAdd.attribute_value_id=attribute.attribute_value_id;
    this.attributeAdd.value=attribute.value;
    this.selectedAttribute=this.departments.find(department=>department.attribute_id==attribute.attribute_id);
    this.btnStatus=1;
  }

  /* Delete the category */

  deleteCategory(attribute){
    if(confirm("Are you sure to delete category - "+attribute.name)){
      this._attributeService.deleteAttribute(attribute)
      .subscribe(
        res=>{
          // @ts-ignore
          window.alert(res.message);
        }
      )
    }
  }

/* Sort Data of table accoriding to various aspects */

sortData(key){
  switch(key){
    case "id":{
      this.sortKey=1;
      if(this.sorting===0 || this.sorting===1){
        this.attributes=this.attributes.sort((first,second)=>first.attribute_value_id-second.attribute_value_id);
        this.sorting=11;
      } else {
        this.attributes=this.attributes.sort((first,second)=>second.attribute_value_id-first.attribute_value_id);
        this.sorting=1;
      }
      break;
    }

    case "value":{
      this.sortKey=2;
      if(this.sorting===0 || this.sorting===1){
        this.attributes=this.attributes.sort((first,second)=>(first.value>second.value?-1:1));
        this.sorting=11;
      } else {
        this.attributes=this.attributes.sort((first,second)=>(first.value>second.value?1:-1));
        this.sorting=1;
      }
      break;
    }

    default:{
      this.sortKey=3;
      if(this.sorting===0 || this.sorting===1){
        this.attributes=this.attributes.sort((first,second)=>(first.dname>second.dname?-1:1));
        this.sorting=11;
      } else {
        this.attributes=this.attributes.sort((first,second)=>(first.dname>second.dname?1:-1));
        this.sorting=1;
      }
      break;
    }
  }
}

  searchAttribute(){
    if(this.search!=""){
      delete this.searchedAttribute;
      this.searchedAttribute=new Array();
      this._attributeService.searchAttributeValue(this.search)
      .subscribe(
        res=>{
          console.log(res)
          // @ts-ignore
          this.searchedAttribute=res;
          let totalPages=this.searchedAttribute.length/this.displayLimit;
          this.setPagination(totalPages);
          this.setSerachedAttributes(1);
        }
      )
    }
  }

  setSerachedAttributes(pageno){
    let limit=(pageno*10)-10;
    if(this.searchedAttribute.length>limit){
      delete this.attributes;
      this.attributes=new Array();
      let i=0;
      if(this.searchedAttribute.length>limit+10){
        limit=pageno*10;
      } else {
        limit=this.searchedAttribute.length;
      }
      for(let j=(pageno*10)-10;j<limit;j++){
        this.attributes[i]=this.searchedAttribute[j];
        i++;
      }
    }
  }

  filterDepartment(department){
    this.filterAttribute=department;
    this._attributeService.getValuesByAttribute(department.attribute_id)
    .subscribe(
      res=>{
        //@ts-ignore
        this.searchedAttribute=res;
        let totalPages=this.searchedAttribute.length/this.displayLimit;
        this.setPagination(totalPages);
        this.setSerachedAttributes(1);
      }
    )
  }

}
