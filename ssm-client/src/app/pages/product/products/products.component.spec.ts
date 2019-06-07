import { async, ComponentFixture, TestBed } from '@angular/core/testing';

import { ProductsComponent } from './products.component';
import { RouterTestingModule } from '@angular/router/testing';
import { HttpClientTestingModule } from '@angular/common/http/testing';
import { HeaderSetter } from 'src/app/core/data/header-setter';
import { ProductService } from 'src/app/core/mock/product.service';


describe('ProductsComponent', () => {
  let component: ProductsComponent;
  let _productService:ProductService;
  let fixture: ComponentFixture<ProductsComponent>;

  beforeEach(async(() => {
    TestBed.configureTestingModule({
      declarations: [ ProductsComponent ],
      imports:[HttpClientTestingModule,RouterTestingModule],
      providers:[HeaderSetter]
    })
    .compileComponents();

  }));

  beforeEach(async() => {
    fixture = TestBed.createComponent(ProductsComponent);
    component = fixture.componentInstance;
   
    component.ngOnInit();
    await fixture.whenStable();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });

  it('should get all products of current page',async(()=>{
    // component.ngOnInit();
    fixture.detectChanges();
    fixture.whenStable().then(()=>{
      expect(component.products.length).toBeGreaterThan(0);
    }) 
  }));
});
