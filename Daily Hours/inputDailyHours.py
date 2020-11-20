from automateHours import WebHelpers
from dotenv import load_dotenv
from pathlib import Path
import datetime
import os


class DailyHours(object):
    env_path = Path('resources') / '.env'
    load_dotenv(dotenv_path=env_path)

    def __init__(self, opts):
        self.__jamis_username = os.getenv('USERNAME_JAMIS')
        self.__jamis_password = os.getenv('PASSWORD_JAMIS')
        self.__today = datetime.date.today()
        self.__date_str = self.previous_saturday()
        self.web = WebHelpers(options=opts)

    def previous_saturday(self):
        idx = (self.__today.weekday() + 1) % 7  # MON = 0, SUN = 6 -> SUN = 0 .. SAT = 6
        sun = self.__today - datetime.timedelta(7+idx-6)
        return f'{sun.month}/{sun.day}/{sun.year}'

    def load_jamis(self):
        self.web.driver.get('https://regulus.jamisprime.com/main')
        user_form = self.web.driver.find_element_by_xpath('//*[@placeholder="My Username"]')
        user_form.send_keys(self.__jamis_username)
        pass_form = self.web.driver.find_element_by_xpath('//*[@placeholder="My Password"]')
        pass_form.send_keys(self.__jamis_password)
        self.web.driver.find_element_by_id('btnLogin').click()
        self.web.driver.find_element_by_xpath('//*[@id="panelT_modulesBar_ul"]/li[7]/div/div').click()
        self.web.driver.get('https://regulus.jamisprime.com/main?ScreenId=WM3045JM')
        self.elem = self.find_element_in_table(self.__date_str)

    def find_element_in_table(self, date_str):
        frame = self.web.driver.find_element_by_tag_name('iframe')
        self.web.driver.switch_to.frame(frame)
        elems = self.web.driver.find_elements_by_xpath('//a[@href]')
        for num, elem in enumerate(elems):
            if elem.text == self.__date_str:
                elems[num].click()
                aaa = 1
                break


if __name__ == '__main__':
    ops = ('start-maximized',
           'disable-infobars')
    test = DailyHours(ops)
    test.load_jamis()

