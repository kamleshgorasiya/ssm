import { Component, OnInit } from '@angular/core';
import { AttributeService } from 'src/app/core/mock/attribute.service';
import { AuthService } from 'src/app/core/mock/auth.service';
import { Router } from '@angular/router';

@Component({
  selector: 'app-manage-attribute',
  templateUrl: './manage-attribute.component.html',
  styleUrls: ['./manage-attribute.component.css']
})
export class ManageAttributeComponent implements OnInit {

  constructor(private _attributeService:AttributeService,
              private _authService:AuthService,
              private _router:Router) { }


  attributes=new Array();
  totalAttributes;
  attributeAdd={
    attribute_id:0,
    name:""
  };
  btnStatus=0;
  displayLimit=10;
  currentPage=1;
  lastPage;
  sorting=0;
  sortKey=0;
  search="";
  searchedAttribute=new Array();
  displayPages=new Array();


  ngOnInit() {

    // If user is not logged in,it will redirect to login

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
      }
    );
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
      this._attributeService.getAllAttributes((pageno*10)-10)
      .subscribe(
        res=>{
          // @ts-ignore
          this.attributes=res; 
        }
      ) 
    } else {
      this.setSerachedAttributes(pageno);
    }  
  }

    /* add Category to database */

    addCategory(){
      if(this.attributeAdd.name.length>0){
        this._attributeService.addAttribute(this.attributeAdd)
        .subscribe(
          res=>{
            window.alert("Attribute is added successfully");
          }
        )
      } else {
        window.alert("Enter the Name of Attributes");
      }
      
    }
  
    /* Update Category to database */
  
    updateCategory(){
      if(this.attributeAdd.name.length>0){
        this._attributeService.updateAttribute(this.attributeAdd)
        .subscribe(
          res=>{
            window.alert("Attribute value updated successfully");
            for(let i=0;i<this.attributes.length;i++){
              if(this.attributes[i].attribute_id==this.attributeAdd.attribute_id){
                this.attributes[i].name=this.attributeAdd.name;
                break;
              }
            }
          }
        )
      } else {
        window.alert("Enter attribute value");
      }
      
    }
  
    /* cancel the add Attribute  */
  
    cancelAttribute(){
      this.attributeAdd.name="";
      this.btnStatus=0;
    }
  
    /* Edit the category */
  
    editCategory(attribute){
      
      this.attributeAdd.attribute_id=attribute.attribute_id;
      this.attributeAdd.name=attribute.name;
      this.btnStatus=1;
    }
  
  /* Sort Data of table accoriding to various aspects */

  sortData(key){
    switch(key){
      case "id":{
        this.sortKey=1;
        if(this.sorting===0 || this.sorting===1){
          this.attributes=this.attributes.sort((first,second)=>first.attribute_id-second.attribute_id);
          this.sorting=11;
        } else {
          this.attributes=this.attributes.sort((first,second)=>second.attribute_id-first.attribute_id);
          this.sorting=1;
        }
        break;
      }

      default:{
        this.sortKey=3;
        if(this.sorting===0 || this.sorting===1){
          this.attributes=this.attributes.sort((first,second)=>(first.name>second.name?-1:1));
          this.sorting=11;
        } else {
          this.attributes=this.attributes.sort((first,second)=>(first.name>second.name?1:-1));
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

}
