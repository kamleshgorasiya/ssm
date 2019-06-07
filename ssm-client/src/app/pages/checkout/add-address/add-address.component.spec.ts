import { async, ComponentFixture, TestBed } from '@angular/core/testing';

import { AddAddressComponent } from './add-address.component';
import { FormsModule } from '@angular/forms';
import { HttpClientTestingModule } from '@angular/common/http/testing';
import { HeaderSetter } from 'src/app/core/data/header-setter';
import { RouterTestingModule } from '@angular/router/testing';

describe('AddAddressComponent', () => {
  let component: AddAddressComponent;
  let fixture: ComponentFixture<AddAddressComponent>;

  beforeEach(async(() => {
    TestBed.configureTestingModule({
      declarations: [ AddAddressComponent ],
      imports:[FormsModule,HttpClientTestingModule,RouterTestingModule],
      providers:[HeaderSetter]
    })
    .compileComponents();
  }));

  beforeEach(() => {
    fixture = TestBed.createComponent(AddAddressComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
