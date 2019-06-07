import { async, ComponentFixture, TestBed } from '@angular/core/testing';

import { ProductDetailComponent } from './product-detail.component';
import { RouterTestingModule } from '@angular/router/testing';
import { HttpClientTestingModule } from '@angular/common/http/testing';
import { HeaderSetter } from 'src/app/core/data/header-setter';
import { By } from '@angular/platform-browser';

describe('ProductDetailComponent', () => {
  let component: ProductDetailComponent;
  let fixture: ComponentFixture<ProductDetailComponent>;

  beforeEach(async(() => {
    TestBed.configureTestingModule({
      declarations: [ ProductDetailComponent ],
      imports:[RouterTestingModule,HttpClientTestingModule],
      providers:[HeaderSetter]
    })
    .compileComponents();
  }));

  beforeEach(() => {
    fixture = TestBed.createComponent(ProductDetailComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', async() => {
    expect(component).toBeTruthy();
  });

  it('should get all data of product which user selected',()=>{
    component.ngOnInit();
    expect(component.products).not.toBeNull();
    expect(component.variants).not.toBeNull();
  });
});
